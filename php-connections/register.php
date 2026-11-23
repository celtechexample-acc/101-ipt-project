<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Allow: POST');
    http_response_code(405);
    exit('Method not allowed.');
}

if (!csrf_token_is_valid()) {
    header('Location: ../portals/Ossa-login.php?error=setup_csrf');
    exit;
}

$name = trim(is_string($_POST['name'] ?? null) ? $_POST['name'] : '');
$email = trim(is_string($_POST['email'] ?? null) ? $_POST['email'] : '');
$password = is_string($_POST['password'] ?? null) ? $_POST['password'] : '';
$confirmation = is_string($_POST['password_confirmation'] ?? null) ? $_POST['password_confirmation'] : '';

function redirect_to_registration(string $error, string $name = '', string $email = ''): never
{
    $query = http_build_query([
        'error' => 'setup_' . $error,
        'name' => substr($name, 0, 100),
        'email' => substr($email, 0, 254),
    ]);
    header('Location: ../portals/Ossa-login.php?' . $query);
    exit;
}

if ($name === '' || strlen($name) > 100) {
    redirect_to_registration('name', $name, $email);
}

if (strlen($email) > 254
    || filter_var($email, FILTER_VALIDATE_EMAIL) === false
    || strtolower(substr($email, strrpos($email, '@') + 1)) !== 'gmail.com') {
    redirect_to_registration('email', $name, $email);
}

if (strlen($password) < 8 || strlen($password) > 4096) {
    redirect_to_registration('password', $name, $email);
}
if (!hash_equals($password, $confirmation)) {
    redirect_to_registration('confirmation', $name, $email);
}

try {
    begin_sqlite_immediate($db);
    $existingAccount = $db->prepare('SELECT 1 FROM users WHERE email = :email COLLATE NOCASE LIMIT 1');
    $existingAccount->execute([':email' => $email]);
    if ($existingAccount->fetchColumn() !== false) {
        $db->rollBack();
        redirect_to_registration('email_taken', $name, $email);
    }

    $passwordHash = password_hash($password, PASSWORD_DEFAULT);
    if (!is_string($passwordHash)) {
        throw new RuntimeException('Could not securely hash the administrator password.');
    }
    $stmt = $db->prepare('INSERT INTO users (name, email, password) VALUES (:name, :email, :password)');
    $stmt->execute([
        ':name' => $name,
        ':email' => $email,
        ':password' => $passwordHash,
    ]);
    $db->commit();
} catch (Throwable $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log($e->getMessage());
    http_response_code(500);
    exit('Something went wrong while creating your account. Please try again later.');
}

header('Location: ../portals/Ossa-login.php?registered=1');
exit;
?>
