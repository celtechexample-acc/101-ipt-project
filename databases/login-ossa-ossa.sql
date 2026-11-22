PRAGMA foreign_keys = ON;

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL COLLATE NOCASE UNIQUE,
    password TEXT NOT NULL,
    session_version INTEGER NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE password_reset_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    otp_hash TEXT NOT NULL,
    expires_at INTEGER NOT NULL,
    attempts INTEGER NOT NULL DEFAULT 0,
    verified_at INTEGER,
    used_at INTEGER,
    request_ip_hash TEXT NOT NULL,
    created_at INTEGER NOT NULL
);
CREATE INDEX password_reset_user_created ON password_reset_requests(user_id, created_at);
CREATE INDEX password_reset_ip_created ON password_reset_requests(request_ip_hash, created_at);

CREATE TABLE user_login_security (
    user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    lockout_level INTEGER NOT NULL DEFAULT 0,
    locked_until INTEGER,
    updated_at INTEGER NOT NULL
);

CREATE TABLE login_ip_security (
    ip_hash TEXT PRIMARY KEY,
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    window_started_at INTEGER NOT NULL,
    locked_until INTEGER,
    updated_at INTEGER NOT NULL
);
CREATE INDEX login_ip_updated ON login_ip_security(updated_at);