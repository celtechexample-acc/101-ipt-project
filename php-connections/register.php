<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Allow: POST');
    http_response_code(405);
    exit('Method not allowed.');
}

if (!csrf_token_is_valid()) {
    http_response_code(400);
    exit('Your form session expired. Return to registration and try again.');
}

$name = trim(is_string($_POST['name'] ?? null) ? $_POST['name'] : '');
$email = trim(is_string($_POST['email'] ?? null) ? $_POST['email'] : '');
$password = is_string($_POST['password'] ?? null) ? $_POST['password'] : '';

function redirect_to_registration(string $error, string $name = '', string $email = ''): never
{
    $query = http_build_query(['error' => $error, 'name' => $name, 'email' => $email]);
    header('Location: ../portals/register.php?' . $query);
    exit;
}

if ($name === '' || strlen($name) > 100) {
    redirect_to_registration('name', $name, $email);
}

if (strlen($email) > 254 || filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
    redirect_to_registration('email', $name, $email);
}

if (strlen($password) < 8 || strlen($password) > 4096) {
    redirect_to_registration('password', $name, $email);
}

try {
    $stmt = $db->prepare('INSERT INTO users (name, email, password) VALUES (:name, :email, :password)');
    $stmt->execute([
        ':name' => $name,
        ':email' => $email,
        ':password' => password_hash($password, PASSWORD_DEFAULT),
    ]);

    session_regenerate_id(true);
    $_SESSION['user_id'] = (int) $db->lastInsertId();
    $_SESSION['user_name'] = $name;
    $_SESSION['session_version'] = 0;
    header('Location: ../dashboard/osa-dashboard.php');
    exit;
} catch (PDOException $e) {
    if (str_contains(strtolower($e->getMessage()), 'unique constraint failed')) {
        redirect_to_registration('exists', $name, $email);
    }

    error_log($e->getMessage());
    http_response_code(500);
    exit('Something went wrong while creating your account. Please try again later.');
}
?>
