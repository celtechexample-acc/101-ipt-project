<?php
declare(strict_types=1);

if (session_status() !== PHP_SESSION_ACTIVE) {
    ini_set('session.use_strict_mode', '1');
    ini_set('session.use_only_cookies', '1');

    $secure = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
    session_set_cookie_params([
        'httponly' => true,
        'secure' => $secure,
        'samesite' => 'Lax',
    ]);
    session_start();
}

require_once __DIR__ . '/../databases/accounts-data.php';

function begin_sqlite_immediate(PDO $db): void
{
    if ($db->inTransaction()) {
        throw new LogicException('A database transaction is already active.');
    }

    $db->exec('BEGIN IMMEDIATE');
}

function csrf_token(): string
{
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }

    return $_SESSION['csrf_token'];
}

function csrf_token_is_valid(): bool
{
    $submittedToken = $_POST['csrf_token'] ?? null;

    return is_string($submittedToken)
        && isset($_SESSION['csrf_token'])
        && hash_equals($_SESSION['csrf_token'], $submittedToken);
}
