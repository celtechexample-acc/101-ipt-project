CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL COLLATE NOCASE,
        password TEXT NOT NULL,
        session_version INTEGER NOT NULL DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
CREATE TABLE sqlite_sequence(name,seq);
CREATE UNIQUE INDEX users_email_unique ON users(email COLLATE NOCASE);
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
CREATE TABLE courses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE year_levels (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    sort_order INTEGER NOT NULL UNIQUE
);
CREATE TABLE sections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
    year_level_id INTEGER NOT NULL REFERENCES year_levels(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(course_id, year_level_id, name)
);
CREATE TABLE students (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_name TEXT NOT NULL,
    enrollment_year INTEGER NOT NULL CHECK (enrollment_year BETWEEN 1959 AND 2026),
    course_id INTEGER REFERENCES courses(id) ON DELETE RESTRICT,
    year_level TEXT NOT NULL,
    section_id INTEGER REFERENCES sections(id) ON DELETE RESTRICT,
    email TEXT UNIQUE,
    email_verified INTEGER NOT NULL DEFAULT 0 CHECK (email_verified IN (0,1)),
    student_status TEXT NOT NULL DEFAULT "SAMPLE",
    is_sample INTEGER NOT NULL DEFAULT 1 CHECK (is_sample IN (0,1)),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(student_name, enrollment_year, course_id, year_level, section_id)
);
CREATE TABLE test_recipients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    display_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE COLLATE NOCASE,
    email_verified INTEGER NOT NULL DEFAULT 0 CHECK (email_verified IN (0,1)),
    is_test_recipient INTEGER NOT NULL DEFAULT 1 CHECK (is_test_recipient IN (0,1)),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX students_enrollment_year_idx ON students(enrollment_year);
CREATE INDEX students_course_idx ON students(course_id);
CREATE INDEX students_year_level_idx ON students(year_level);
CREATE INDEX students_section_idx ON students(section_id);
CREATE INDEX students_name_idx ON students(student_name);
CREATE INDEX students_email_idx ON students(email);
CREATE INDEX test_recipients_email_idx ON test_recipients(email);
