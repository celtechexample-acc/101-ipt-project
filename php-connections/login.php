<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/login-security.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Allow: POST');
    http_response_code(405);
    exit('Method not allowed.');
}

if (!csrf_token_is_valid()) {
    header('Location: ../portals/Ossa-login.php?error=csrf');
    exit;
}

$email = trim(is_string($_POST['email'] ?? null) ? $_POST['email'] : '');
$password = is_string($_POST['password'] ?? null) ? $_POST['password'] : '';

if ($email === '' || strlen($email) > 254 || $password === '') {
    header('Location: ../portals/Ossa-login.php?error=both');
    exit;
}

$now = time();
$ipHash = login_security_ip_hash();
$ipRemaining = ip_login_lockout_remaining($db, $ipHash, $now);
if ($ipRemaining > 0) {
    header('Location: ../portals/Ossa-login.php?' . http_build_query([
        'error' => 'locked',
        'until' => $now + $ipRemaining,
        'email' => $email,
    ]));
    exit;
}

$stmt = $db->prepare('
    SELECT id, name, password, session_version
    FROM users
    WHERE email = :email COLLATE NOCASE
      AND id = (SELECT MIN(id) FROM users)
    LIMIT 1
');
$stmt->execute([':email' => $email]);
$user = $stmt->fetch();

$accountRemaining = $user === false
    ? 0
    : user_login_lockout_remaining($db, (int) $user['id'], $now);
if ($accountRemaining > 0) {
    header('Location: ../portals/Ossa-login.php?' . http_build_query([
        'error' => 'locked',
        'until' => $now + $accountRemaining,
        'email' => $email,
    ]));
    exit;
}

if ($user === false || !password_verify($password, $user['password'])) {
    $remaining = record_failed_login(
        $db,
        $user === false ? null : (int) $user['id'],
        $ipHash,
        $now
    );
    if ($remaining > 0) {
        header('Location: ../portals/Ossa-login.php?' . http_build_query([
            'error' => 'locked',
            'until' => $now + $remaining,
            'email' => $email,
        ]));
        exit;
    }

    header('Location: ../portals/Ossa-login.php?error=both&email=' . rawurlencode($email));
    exit;
}

$remaining = record_successful_login($db, (int) $user['id'], $ipHash, $now);
if ($remaining > 0) {
    header('Location: ../portals/Ossa-login.php?' . http_build_query([
        'error' => 'locked',
        'until' => $now + $remaining,
        'email' => $email,
    ]));
    exit;
}

session_regenerate_id(true);
$_SESSION['user_id'] = (int) $user['id'];
$_SESSION['user_name'] = $user['name'];
$_SESSION['session_version'] = (int) $user['session_version'];

header('Location: ../dashboard/osa-dashboard.php');
exit;
