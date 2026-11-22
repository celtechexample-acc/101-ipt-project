<?php
declare(strict_types=1);

$dbFolder = __DIR__ . '/data';

if (!is_dir($dbFolder) && !mkdir($dbFolder, 0775, true) && !is_dir($dbFolder)) {
    throw new RuntimeException('Could not create the SQLite database directory.');
}

$db = new PDO('sqlite:' . $dbFolder . '/celtech_osa.db');
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
$db->exec('PRAGMA foreign_keys = ON');
$db->exec('PRAGMA busy_timeout = 5000');

$db->exec("
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL COLLATE NOCASE,
        password TEXT NOT NULL,
        session_version INTEGER NOT NULL DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
");

$columns = $db->query('PRAGMA table_info(users)')->fetchAll(PDO::FETCH_COLUMN, 1);
if (!in_array('email', $columns, true)) {
    $db->exec('ALTER TABLE users ADD COLUMN email TEXT COLLATE NOCASE');
}
if (!in_array('session_version', $columns, true)) {
    $db->exec('ALTER TABLE users ADD COLUMN session_version INTEGER NOT NULL DEFAULT 0');
}

$db->exec('CREATE UNIQUE INDEX IF NOT EXISTS users_email_unique ON users(email COLLATE NOCASE)');

$db->exec("
    CREATE TABLE IF NOT EXISTS password_reset_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        otp_hash TEXT NOT NULL,
        expires_at INTEGER NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        verified_at INTEGER,
        used_at INTEGER,
        request_ip_hash TEXT NOT NULL,
        created_at INTEGER NOT NULL
    )
");
$db->exec('CREATE INDEX IF NOT EXISTS password_reset_user_created ON password_reset_requests(user_id, created_at)');
$db->exec('CREATE INDEX IF NOT EXISTS password_reset_ip_created ON password_reset_requests(request_ip_hash, created_at)');

$db->exec("
    CREATE TABLE IF NOT EXISTS user_login_security (
        user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
        failed_attempts INTEGER NOT NULL DEFAULT 0,
        lockout_level INTEGER NOT NULL DEFAULT 0,
        locked_until INTEGER,
        updated_at INTEGER NOT NULL
    )
");

$db->exec("
    CREATE TABLE IF NOT EXISTS login_ip_security (
        ip_hash TEXT PRIMARY KEY,
        failed_attempts INTEGER NOT NULL DEFAULT 0,
        window_started_at INTEGER NOT NULL,
        locked_until INTEGER,
        updated_at INTEGER NOT NULL
    )
");
$db->exec('CREATE INDEX IF NOT EXISTS login_ip_updated ON login_ip_security(updated_at)');

$studentSqlPath = __DIR__ . '/students.sql';
if (is_file($studentSqlPath)) {
    $studentSql = file_get_contents($studentSqlPath);
    if ($studentSql === false) {
        throw new RuntimeException('Could not read the student database schema.');
    }
    $db->exec($studentSql);
}
?>
