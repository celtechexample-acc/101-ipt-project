<?php
declare(strict_types=1);

require_once __DIR__ . '/password-reset-common.php';
require_once __DIR__ . '/mailer.php';

password_reset_require_post();
password_reset_require_csrf();
unset($_SESSION['password_reset_request_id'], $_SESSION['password_reset_verified_id']);

$genericResponse = [
    'ok' => true,
    'message' => 'If an account matches that email and email delivery is available, a verification code will be sent shortly.',
];
$email = trim(is_string($_POST['email'] ?? null) ? $_POST['email'] : '');
if (strlen($email) > 254 || filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
    password_reset_json_response(['ok' => false, 'message' => 'Enter a valid email address.'], 422);
}

$stmt = $db->prepare('SELECT id, email FROM users WHERE email = :email COLLATE NOCASE LIMIT 1');
$stmt->execute([':email' => $email]);
$user = $stmt->fetch();
if ($user === false) {
    password_reset_json_response($genericResponse);
}

$now = time();
$ipHash = password_reset_ip_hash();
begin_sqlite_immediate($db);
try {
    $now = time();
    $stmt = $db->prepare('
        SELECT
            MAX(CASE WHEN created_at > :recent_cutoff THEN created_at END) AS latest_request,
            SUM(CASE WHEN created_at > :hour_cutoff THEN 1 ELSE 0 END) AS account_requests
        FROM password_reset_requests
        WHERE user_id = :user_id
    ');
    $stmt->execute([
        ':recent_cutoff' => $now - 60,
        ':hour_cutoff' => $now - 3600,
        ':user_id' => (int) $user['id'],
    ]);
    $rates = $stmt->fetch();
    $stmt = $db->prepare('SELECT COUNT(*) FROM password_reset_requests WHERE request_ip_hash = :ip_hash AND created_at > :hour_cutoff');
    $stmt->execute([':ip_hash' => $ipHash, ':hour_cutoff' => $now - 3600]);
    $ipRequests = (int) $stmt->fetchColumn();
    if (($rates['latest_request'] !== null && (int) $rates['latest_request'] > $now - 60)
        || (int) $rates['account_requests'] >= 5
        || $ipRequests >= 20) {
        $db->rollBack();
        password_reset_json_response($genericResponse);
    }

    $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
    $stmt = $db->prepare('DELETE FROM password_reset_requests WHERE created_at < :cutoff');
    $stmt->execute([':cutoff' => $now - 86400]);
    $stmt = $db->prepare('UPDATE password_reset_requests SET used_at = :now WHERE user_id = :user_id AND used_at IS NULL');
    $stmt->execute([':now' => $now, ':user_id' => (int) $user['id']]);
    $stmt = $db->prepare('
        INSERT INTO password_reset_requests
            (user_id, otp_hash, expires_at, attempts, request_ip_hash, created_at)
        VALUES
            (:user_id, :otp_hash, :expires_at, 0, :ip_hash, :created_at)
    ');
    $stmt->execute([
        ':user_id' => (int) $user['id'],
        ':otp_hash' => password_hash($otp, PASSWORD_DEFAULT),
        ':expires_at' => $now + 600,
        ':ip_hash' => $ipHash,
        ':created_at' => $now,
    ]);
    $requestId = (int) $db->lastInsertId();
    $db->commit();
} catch (Throwable $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    throw $e;
}

try {
    send_password_reset_email((string) $user['email'], $otp);
} catch (PHPMailer\PHPMailer\Exception | RuntimeException $e) {
    error_log('Password reset email delivery failed: ' . $e->getMessage());
    $stmt = $db->prepare('UPDATE password_reset_requests SET used_at = :now WHERE id = :id AND used_at IS NULL');
    $stmt->execute([':now' => time(), ':id' => $requestId]);
    password_reset_json_response($genericResponse);
}

$_SESSION['password_reset_request_id'] = $requestId;
password_reset_json_response($genericResponse);
