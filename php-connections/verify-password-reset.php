<?php
declare(strict_types=1);

require_once __DIR__ . '/password-reset-common.php';

password_reset_require_post();
password_reset_require_csrf();

$requestId = $_SESSION['password_reset_request_id'] ?? null;
$code = is_string($_POST['code'] ?? null) ? trim($_POST['code']) : '';
if (!is_int($requestId) || !preg_match('/^\d{6}$/D', $code)) {
    password_reset_json_response(['ok' => false, 'message' => 'That code is invalid or expired.'], 400);
}

$now = time();
begin_sqlite_immediate($db);
try {
    $stmt = $db->prepare('
        SELECT otp_hash
        FROM password_reset_requests
        WHERE id = :id AND expires_at > :now AND used_at IS NULL
            AND verified_at IS NULL AND attempts < 5
    ');
    $stmt->execute([':id' => $requestId, ':now' => $now]);
    $request = $stmt->fetch();
    if ($request === false) {
        $db->rollBack();
        password_reset_json_response(['ok' => false, 'message' => 'That code is invalid or expired.'], 400);
    }

    if (!password_verify($code, $request['otp_hash'])) {
        $stmt = $db->prepare('
            UPDATE password_reset_requests
            SET attempts = attempts + 1
            WHERE id = :id AND verified_at IS NULL AND used_at IS NULL AND attempts < 5
        ');
        $stmt->execute([':id' => $requestId]);
        $db->commit();
        password_reset_json_response(['ok' => false, 'message' => 'That code is invalid or expired.'], 400);
    }

    $stmt = $db->prepare('
        UPDATE password_reset_requests
        SET verified_at = :now
        WHERE id = :id AND expires_at > :now AND used_at IS NULL
            AND verified_at IS NULL AND attempts < 5
    ');
    $stmt->execute([':id' => $requestId, ':now' => $now]);
    if ($stmt->rowCount() !== 1) {
        $db->rollBack();
        password_reset_json_response(['ok' => false, 'message' => 'That code is invalid or expired.'], 400);
    }
    $db->commit();
} catch (Throwable $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    throw $e;
}

session_regenerate_id(true);
$_SESSION['password_reset_verified_id'] = $requestId;
password_reset_json_response(['ok' => true, 'message' => 'Code verified.']);
