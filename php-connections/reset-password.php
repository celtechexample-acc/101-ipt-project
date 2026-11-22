<?php
declare(strict_types=1);

require_once __DIR__ . '/password-reset-common.php';

password_reset_require_post();
password_reset_require_csrf();

$requestId = $_SESSION['password_reset_verified_id'] ?? null;
$password = is_string($_POST['password'] ?? null) ? $_POST['password'] : '';
$confirmation = is_string($_POST['password_confirmation'] ?? null) ? $_POST['password_confirmation'] : '';
if (strlen($password) < 8 || strlen($password) > 4096) {
    password_reset_json_response(['ok' => false, 'message' => 'Use a password between 8 and 4096 characters.'], 422);
}
if (!hash_equals($password, $confirmation)) {
    password_reset_json_response(['ok' => false, 'message' => 'The passwords do not match.'], 422);
}
if (!is_int($requestId)) {
    password_reset_json_response(['ok' => false, 'message' => 'Verify a current code before changing your password.'], 400);
}

$now = time();
begin_sqlite_immediate($db);
try {
    $stmt = $db->prepare('
        SELECT user_id
        FROM password_reset_requests
        WHERE id = :id AND verified_at IS NOT NULL AND used_at IS NULL AND expires_at > :now
    ');
    $stmt->execute([':id' => $requestId, ':now' => $now]);
    $request = $stmt->fetch();
    if ($request === false) {
        $db->rollBack();
        unset($_SESSION['password_reset_verified_id']);
        password_reset_json_response(['ok' => false, 'message' => 'Your reset authorization expired. Request a new code.'], 400);
    }

    $stmt = $db->prepare('UPDATE users SET password = :password, session_version = session_version + 1 WHERE id = :user_id');
    $stmt->execute([
        ':password' => password_hash($password, PASSWORD_DEFAULT),
        ':user_id' => (int) $request['user_id'],
    ]);
    if ($stmt->rowCount() !== 1) {
        throw new RuntimeException('The password reset account no longer exists.');
    }

    $stmt = $db->prepare('UPDATE password_reset_requests SET used_at = :now, otp_hash = :empty_hash WHERE id = :id');
    $stmt->execute([':now' => $now, ':empty_hash' => '', ':id' => $requestId]);
    $db->commit();
} catch (Throwable $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    throw $e;
}

unset($_SESSION['password_reset_request_id'], $_SESSION['password_reset_verified_id']);
password_reset_json_response(['ok' => true, 'message' => 'Your password has been updated.']);
