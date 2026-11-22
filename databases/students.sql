PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS courses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT OR IGNORE INTO courses (code, name, is_active)
VALUES ("BSIT", "Bachelor of Science in Information Technology", 1);

CREATE TABLE IF NOT EXISTS year_levels (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    sort_order INTEGER NOT NULL UNIQUE
);

INSERT OR IGNORE INTO year_levels (name, sort_order) VALUES
("1st Year", 1), ("2nd Year", 2), ("3rd Year", 3), ("4th Year", 4);

CREATE TABLE IF NOT EXISTS sections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
    year_level_id INTEGER NOT NULL REFERENCES year_levels(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(course_id, year_level_id, name)
);

INSERT OR IGNORE INTO sections (course_id, year_level_id, name)
SELECT c.id, y.id, s.name
FROM courses c
JOIN year_levels y
JOIN (SELECT "Section A" AS name UNION ALL SELECT "Section B") s
WHERE c.code = "BSIT";

CREATE TABLE IF NOT EXISTS students (
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

CREATE TABLE IF NOT EXISTS test_recipients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    display_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE COLLATE NOCASE,
    email_verified INTEGER NOT NULL DEFAULT 0 CHECK (email_verified IN (0,1)),
    is_test_recipient INTEGER NOT NULL DEFAULT 1 CHECK (is_test_recipient IN (0,1)),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT OR IGNORE INTO test_recipients (display_name, email, email_verified, is_test_recipient)
VALUES ("Test Recipient 1", "ron2mesiano12@gmail.com", 0, 1),
       ("Test Recipient 2", "mlmesiano@gmail.com", 0, 1);

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Rose Gomez", 1959, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jose Grace Reyes", 1959, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Teresa Anne Villanueva", 1959, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Renzo Marie Panganiban", 1959, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Marie Uy", 1959, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kyla Paolo Flores", 1959, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Chloe Marie Valdez", 1959, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Angel Flores", 1959, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mark Anne Sanchez", 1959, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Grace Garcia", 1959, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lea Luis Santiago", 1960, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samantha Angel Velasco", 1960, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nathaniel Paolo Mendoza", 1960, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Isabella Paolo Morales", 1960, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Vincent Anne Soriano", 1960, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Luis Gomez", 1960, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Marco Angel Dela Cruz", 1960, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Vincent Marie Rivera", 1960, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Trisha Paolo Perez", 1960, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Teresa Jose Reyes", 1960, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Daniel Luis Aquino", 1961, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Gabriel Jose Velasco", 1961, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Hazel Antonio Soriano", 1961, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nico Luis Mendoza", 1961, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Daniel Antonio Dizon", 1961, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alex Paolo Valdez", 1961, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Maria Valdez", 1961, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Adrian Antonio Silva", 1961, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rafael Marie Gutierrez", 1961, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Maria Marie Soriano", 1961, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Darren Paolo Tan", 1962, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Marie Martinez", 1962, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Paolo Soriano", 1962, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Angel Soriano", 1962, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Anne Soriano", 1962, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Neil Rose Torres", 1962, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Trisha Luis Torres", 1962, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Daniel Maria Mercado", 1962, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Jose Garcia", 1962, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Marco Marie Santos", 1962, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Antonio Castillo", 1963, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alyssa Luis Ortega", 1963, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Amara Luis Dizon", 1963, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andrea Rose Soriano", 1963, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Antonio Fernandez", 1963, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bryan Paolo Cruz", 1963, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Vincent Anne Santiago", 1963, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Maria Lopez", 1963, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Aira Luis Villanueva", 1963, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Diego Paolo Bautista", 1963, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Marie Rosales", 1964, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Angel Valdez", 1964, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kyla Antonio Tan", 1964, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Angela Marie Rivera", 1964, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Maria Dela Cruz", 1964, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Antonio Uy", 1964, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rafael Paolo Gomez", 1964, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kristine Maria Ramos", 1964, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Rose Flores", 1964, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Marie Bautista", 1964, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Marie Uy", 1965, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Angel Dela Cruz", 1965, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Christian Grace Panganiban", 1965, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Vincent Maria Tan", 1965, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mark Antonio Soriano", 1965, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Antonio Dominguez", 1965, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Luis Reyes", 1965, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Aira Grace Valdez", 1965, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lea Grace Valdez", 1965, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Teresa Antonio Cruz", 1965, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Teresa Luis Uy", 1966, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Antonio Velasco", 1966, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nicole Luis Sanchez", 1966, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Antonio Mendoza", 1966, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nathaniel Maria Reyes", 1966, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Antonio Soriano", 1966, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Angel Dominguez", 1966, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Angel Magsaysay", 1966, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Anne Ortega", 1966, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Paolo Lim", 1966, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Jose Santiago", 1967, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kristine Grace Sanchez", 1967, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Gabriel Maria Cruz", 1967, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Camille Maria Mendoza", 1967, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Jose Soriano", 1967, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Antonio Fernandez", 1967, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ella Angel Martinez", 1967, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bryan Paolo Dominguez", 1967, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Luis Aquino", 1967, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Darren Rose Castillo", 1967, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bea Luis Castillo", 1968, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Marco Grace Santiago", 1968, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Antonio Martinez", 1968, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Marie Valdez", 1968, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Jose Silva", 1968, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Maria Castillo", 1968, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patricia Paolo Mendoza", 1968, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alyssa Anne Rosales", 1968, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Antonio Rosales", 1968, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Maria Dominguez", 1968, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Rose Valdez", 1969, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jason Jose Torres", 1969, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Aira Antonio Cruz", 1969, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kyla Luis Mercado", 1969, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Angela Marie Santos", 1969, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Chloe Grace Ramos", 1969, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lea Anne Perez", 1969, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Jose Torres", 1969, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Maria Castillo", 1969, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Jose Mendoza", 1969, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Gabriel Angel Morales", 1970, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Anne Aquino", 1970, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patricia Paolo Morales", 1970, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Daniel Maria Magsaysay", 1970, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Paolo Morales", 1970, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Luis Santos", 1970, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Luis Panganiban", 1970, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Enzo Paolo Lopez", 1970, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alyssa Luis Reyes", 1970, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Anne Soriano", 1970, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ivan Marie Dizon", 1971, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Maria Angel Santos", 1971, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Antonio Reyes", 1971, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Anne Uy", 1971, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alex Rose Ramos", 1971, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Paolo Rivera", 1971, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Marco Angel Aquino", 1971, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Paolo Tan", 1971, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Jose Panganiban", 1971, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nicole Grace Santiago", 1971, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Anne Lim", 1972, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Caleb Luis Torres", 1972, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Maria Uy", 1972, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kristine Paolo Uy", 1972, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Grace Martinez", 1972, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Rose Santiago", 1972, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Grace Gutierrez", 1972, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Isabella Anne Villanueva", 1972, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Luis Santos", 1972, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Rose Tan", 1972, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andrea Rose Dominguez", 1973, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Grace Perez", 1973, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Antonio Torres", 1973, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Maria Garcia", 1973, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Angela Jose Gomez", 1973, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Anne Santos", 1973, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Grace Navarro", 1973, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Renzo Anne Garcia", 1973, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Enzo Antonio Gutierrez", 1973, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Antonio Navarro", 1973, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samantha Jose Velasco", 1974, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bryan Rose Castillo", 1974, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Paolo Soriano", 1974, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Marco Angel Torres", 1974, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Anne Perez", 1974, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Monique Grace Gomez", 1974, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Marco Paolo Soriano", 1974, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Angela Grace Navarro", 1974, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Maria Anne Soriano", 1974, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Chloe Rose Fernandez", 1974, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Paolo Rosales", 1975, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Trisha Grace Velasco", 1975, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Grace Dizon", 1975, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Hazel Angel Flores", 1975, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Trisha Paolo Aquino", 1975, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Maria Jose Gomez", 1975, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Teresa Jose Santos", 1975, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nico Grace Dizon", 1975, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Paolo Dela Cruz", 1975, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Rose Torres", 1975, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Hazel Antonio Valdez", 1976, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Rose Martinez", 1976, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Grace Navarro", 1976, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Diego Jose Morales", 1976, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Amara Rose Martinez", 1976, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jason Grace Panganiban", 1976, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bea Angel Soriano", 1976, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Maria Morales", 1976, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Jose Valdez", 1976, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Grace Sanchez", 1976, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Marie Cruz", 1977, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Paolo Cruz", 1977, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Luis Aquino", 1977, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Rose Magsaysay", 1977, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Angela Luis Dela Cruz", 1977, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andrea Jose Dominguez", 1977, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bryan Maria Garcia", 1977, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Hazel Angel Torres", 1977, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Paolo Tan", 1977, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Gabriel Angel Gutierrez", 1977, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Jose Perez", 1978, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Diego Marie Lopez", 1978, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Monique Jose Gutierrez", 1978, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Grace Perez", 1978, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Anne Panganiban", 1978, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Amara Paolo Bautista", 1978, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jose Antonio Santos", 1978, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ivan Paolo Reyes", 1978, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Angel Sanchez", 1978, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Antonio Panganiban", 1978, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alex Paolo Bautista", 1979, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Paolo Lim", 1979, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nathaniel Paolo Sanchez", 1979, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Marco Antonio Soriano", 1979, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Jose Gomez", 1979, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Angel Dela Cruz", 1979, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Grace Dela Cruz", 1979, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mark Marie Valdez", 1979, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Maria Rivera", 1979, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Marie Torres", 1979, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Renzo Rose Sanchez", 1980, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Angela Antonio Silva", 1980, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nathaniel Paolo Reyes", 1980, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Gabriel Marie Soriano", 1980, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Paolo Sanchez", 1980, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Luis Navarro", 1980, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Marie Ortega", 1980, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Isabella Angel Soriano", 1980, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Isabella Angel Dominguez", 1980, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Antonio Sanchez", 1980, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Anne De Leon", 1981, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Grace Fernandez", 1981, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Anne Tan", 1981, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Rose Gomez", 1981, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Jose Panganiban", 1981, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Luis Torres", 1981, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Hazel Grace Lopez", 1981, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Luis Gomez", 1981, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Marie Garcia", 1981, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Daniel Anne Fernandez", 1981, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rafael Jose Rosales", 1982, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Paolo Silva", 1982, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Antonio Lim", 1982, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Maria Luis Santos", 1982, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Amara Anne Dominguez", 1982, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Darren Antonio Tan", 1982, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Diego Paolo Mercado", 1982, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Anne Gomez", 1982, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alex Maria Ramos", 1982, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Grace Santiago", 1982, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Aira Jose Dela Cruz", 1983, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Grace Flores", 1983, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Luis Villanueva", 1983, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Camille Anne Fernandez", 1983, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Aira Paolo Martinez", 1983, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andrea Rose Rivera", 1983, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Chloe Jose Rivera", 1983, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Enzo Antonio Soriano", 1983, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Antonio Mendoza", 1983, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Rose Mendoza", 1983, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Antonio Mendoza", 1984, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Luis Lim", 1984, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Jose Sanchez", 1984, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Anne Gutierrez", 1984, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Marie Dizon", 1984, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samantha Grace Ortega", 1984, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alex Rose Mendoza", 1984, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bea Paolo Fernandez", 1984, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Jose Magsaysay", 1984, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alex Antonio Morales", 1984, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Antonio Uy", 1985, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alyssa Maria Magsaysay", 1985, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Luis Gutierrez", 1985, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Marie Gutierrez", 1985, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Antonio Cruz", 1985, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Trisha Rose Fernandez", 1985, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bryan Paolo Valdez", 1985, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Rose Gomez", 1985, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Paolo Bautista", 1985, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jason Jose Santiago", 1985, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Rose Martinez", 1986, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Maria Santos", 1986, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mark Marie Rosales", 1986, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Anne Navarro", 1986, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Angel Lopez", 1986, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Chloe Grace Silva", 1986, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alyssa Jose Santos", 1986, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bea Luis Tan", 1986, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Antonio Fernandez", 1986, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Renzo Angel Castillo", 1986, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Luis Ramos", 1987, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Neil Grace Perez", 1987, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Grace Lim", 1987, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Caleb Maria Rivera", 1987, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Christian Paolo Tan", 1987, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mark Paolo Reyes", 1987, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Anne Mercado", 1987, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Darren Maria Uy", 1987, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Jose Morales", 1987, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Monique Jose Gomez", 1987, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Jose Gomez", 1988, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kristine Jose Valdez", 1988, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Antonio Santiago", 1988, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Maria Navarro", 1988, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ella Anne Garcia", 1988, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Luis Silva", 1988, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Luis Reyes", 1988, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jose Jose Santiago", 1988, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Jose Soriano", 1988, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Adrian Anne Lim", 1988, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Angel Silva", 1989, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Grace Rivera", 1989, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Angel Uy", 1989, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Marie Aquino", 1989, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Maria Panganiban", 1989, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Luis Soriano", 1989, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jose Grace Perez", 1989, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Anne Tan", 1989, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Monique Angel Rivera", 1989, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Grace Dominguez", 1989, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Grace Morales", 1990, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Trisha Anne Garcia", 1990, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Marie Dela Cruz", 1990, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Jose Santiago", 1990, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bea Antonio Lim", 1990, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Luis Dela Cruz", 1990, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Paolo Soriano", 1990, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Enzo Rose Garcia", 1990, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Caleb Anne Valdez", 1990, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Maria Rosales", 1990, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alyssa Angel Sanchez", 1991, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Maria Soriano", 1991, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ella Maria Santiago", 1991, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Rose Dominguez", 1991, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mark Jose Perez", 1991, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Angel Silva", 1991, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Paolo Perez", 1991, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kyla Grace Perez", 1991, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Gabriel Marie Flores", 1991, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mark Angel Ramos", 1991, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Anne Cruz", 1992, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kyla Antonio Navarro", 1992, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Maria Ramos", 1992, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patricia Marie Mendoza", 1992, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Aira Anne Castillo", 1992, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Renzo Luis Navarro", 1992, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Luis Bautista", 1992, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Anne Rosales", 1992, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Enzo Paolo Castillo", 1992, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Paolo Aquino", 1992, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Anne Mendoza", 1993, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Angel Soriano", 1993, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Paolo Santos", 1993, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Luis Soriano", 1993, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Angela Rose Bautista", 1993, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Caleb Antonio Gomez", 1993, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kyla Rose Panganiban", 1993, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Jose Rivera", 1993, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alex Marie Tan", 1993, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Erika Grace Dela Cruz", 1993, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Maria Torres", 1994, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Diego Paolo Sanchez", 1994, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nathaniel Maria Santiago", 1994, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Luis Soriano", 1994, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ella Angel Lim", 1994, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Luis Castillo", 1994, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Anne Ramos", 1994, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jose Anne Reyes", 1994, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Enzo Grace Flores", 1994, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Teresa Grace Mercado", 1994, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Isabella Marie Aquino", 1995, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Caleb Angel Morales", 1995, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Marie Reyes", 1995, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kyla Rose Silva", 1995, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Anne Gomez", 1995, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jose Anne Santiago", 1995, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Monique Antonio Santos", 1995, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Marie Santos", 1995, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Jose Sanchez", 1995, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Angel Castillo", 1995, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Angela Rose Castillo", 1996, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Marie Mercado", 1996, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Anne Gomez", 1996, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Marie Santos", 1996, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rafael Rose Rosales", 1996, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nicole Luis Garcia", 1996, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Angel Torres", 1996, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Luis Dizon", 1996, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samantha Anne Gutierrez", 1996, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Angel Magsaysay", 1996, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mark Grace De Leon", 1997, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Grace Uy", 1997, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Paolo Martinez", 1997, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Angel Dominguez", 1997, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patricia Anne Gomez", 1997, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Luis Lopez", 1997, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Angel Soriano", 1997, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Darren Anne Dela Cruz", 1997, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Amara Maria Santiago", 1997, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Angela Grace Fernandez", 1997, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Jose Torres", 1998, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lea Antonio Tan", 1998, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Luis Ramos", 1998, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Anne Silva", 1998, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Grace De Leon", 1998, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Maria Ramos", 1998, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Jose Tan", 1998, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bea Paolo De Leon", 1998, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alyssa Antonio Panganiban", 1998, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bryan Anne Velasco", 1998, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Neil Rose Reyes", 1999, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Adrian Angel Castillo", 1999, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Luis Flores", 1999, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Antonio Rivera", 1999, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Jose Magsaysay", 1999, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lea Maria Tan", 1999, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Marie Lopez", 1999, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Jose Aquino", 1999, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Erika Grace Martinez", 1999, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Jose Soriano", 1999, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Rose Sanchez", 2000, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Isabella Maria Aquino", 2000, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Adrian Jose Rosales", 2000, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Enzo Antonio Mercado", 2000, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Grace Aquino", 2000, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jason Paolo Magsaysay", 2000, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Paolo Magsaysay", 2000, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Rose Santiago", 2000, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Trisha Anne Sanchez", 2000, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Rose Mendoza", 2000, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patricia Antonio Fernandez", 2001, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Grace Lopez", 2001, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Luis Castillo", 2001, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Marie Morales", 2001, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Angel Velasco", 2001, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ivan Paolo Velasco", 2001, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Marie Soriano", 2001, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Hazel Marie Gomez", 2001, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Angel Navarro", 2001, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Camille Marie Ramos", 2001, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Grace Rivera", 2002, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jason Rose Silva", 2002, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Anne Lopez", 2002, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Jose Santiago", 2002, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Antonio Torres", 2002, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Angel Dizon", 2002, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Luis Velasco", 2002, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nathaniel Luis Reyes", 2002, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Maria Navarro", 2002, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Rose Valdez", 2002, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Jose Flores", 2003, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Neil Rose Villanueva", 2003, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Marie Lopez", 2003, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Marie Villanueva", 2003, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bea Angel Mendoza", 2003, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Rose Morales", 2003, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Neil Marie Dela Cruz", 2003, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Anne Sanchez", 2003, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Rose Martinez", 2003, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Rose Navarro", 2003, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alex Jose Tan", 2004, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Caleb Grace Villanueva", 2004, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Marie Sanchez", 2004, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Marie Garcia", 2004, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Adrian Marie De Leon", 2004, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Monique Rose Rosales", 2004, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Marie Tan", 2004, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Maria Gomez", 2004, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patricia Rose Aquino", 2004, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Maria Luis De Leon", 2004, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Rose Garcia", 2005, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Luis Lopez", 2005, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samantha Jose Aquino", 2005, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samantha Maria Villanueva", 2005, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Paolo Navarro", 2005, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Diego Luis Lopez", 2005, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Antonio Garcia", 2005, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Rose Martinez", 2005, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nathaniel Antonio Perez", 2005, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Erika Angel Dizon", 2005, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Rose Panganiban", 2006, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Neil Grace Magsaysay", 2006, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Angel Dela Cruz", 2006, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Grace Cruz", 2006, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Renzo Anne De Leon", 2006, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Anne Gomez", 2006, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lea Paolo Rivera", 2006, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Paolo Cruz", 2006, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Teresa Jose Silva", 2006, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Monique Luis Silva", 2006, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mark Anne Mendoza", 2007, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Rose Rosales", 2007, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nico Antonio Santos", 2007, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Diego Marie Dizon", 2007, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Paolo Martinez", 2007, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Jose Soriano", 2007, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Renzo Jose Aquino", 2007, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kyla Anne Cruz", 2007, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Marie Aquino", 2007, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nico Luis Garcia", 2007, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Rose Gutierrez", 2008, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Maria Castillo", 2008, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Marie Silva", 2008, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Neil Angel Sanchez", 2008, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Rose Rosales", 2008, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Aira Rose Ramos", 2008, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Chloe Maria Ramos", 2008, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patricia Rose Soriano", 2008, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Angel Ortega", 2008, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Rose Rosales", 2008, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Luis Dominguez", 2009, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Maria Reyes", 2009, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Diego Grace De Leon", 2009, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nathaniel Paolo Uy", 2009, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samantha Maria Gutierrez", 2009, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Erika Maria Santiago", 2009, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jose Luis Soriano", 2009, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Grace Dela Cruz", 2009, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Renzo Grace Flores", 2009, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Teresa Paolo Fernandez", 2009, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Angel Bautista", 2010, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Christian Marie De Leon", 2010, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kristine Anne Lopez", 2010, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Jose Perez", 2010, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Maria Jose Navarro", 2010, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Camille Luis Martinez", 2010, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Jose Soriano", 2010, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Amara Angel Torres", 2010, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Erika Marie Panganiban", 2010, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Rose Reyes", 2010, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Rose Gomez", 2011, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Anne Navarro", 2011, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Anne Dela Cruz", 2011, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Luis Fernandez", 2011, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nico Rose Santos", 2011, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nathaniel Jose Santiago", 2011, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Christian Angel Rosales", 2011, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kyla Paolo Rivera", 2011, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Rose Mendoza", 2011, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Maria Rosales", 2011, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jose Maria Silva", 2012, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bryan Antonio Navarro", 2012, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Angel Dizon", 2012, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Erika Marie Perez", 2012, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Maria Tan", 2012, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Jose Tan", 2012, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Hazel Luis Villanueva", 2012, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Amara Maria Magsaysay", 2012, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Neil Anne Aquino", 2012, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andrea Marie Ramos", 2012, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Jose Silva", 2013, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Adrian Luis Cruz", 2013, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Jose Santos", 2013, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Antonio Mercado", 2013, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Luis Velasco", 2013, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Grace Santiago", 2013, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ella Rose Tan", 2013, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nicole Anne Tan", 2013, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Adrian Marie Martinez", 2013, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Chloe Luis Rosales", 2013, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Trisha Grace Soriano", 2014, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Katrina Jose Santiago", 2014, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ivan Paolo Magsaysay", 2014, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Angel Ramos", 2014, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Angel Garcia", 2014, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Luis Velasco", 2014, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Anne Magsaysay", 2014, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Anne Villanueva", 2014, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Antonio Sanchez", 2014, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Rose Silva", 2014, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Teresa Maria Velasco", 2015, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Marie Lopez", 2015, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rafael Antonio Magsaysay", 2015, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Paolo Ortega", 2015, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Paolo Sanchez", 2015, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Isabella Luis Santos", 2015, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jason Marie Velasco", 2015, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Isabella Antonio Garcia", 2015, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samantha Maria Garcia", 2015, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Grace Aquino", 2015, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Neil Angel Dominguez", 2016, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Jose Mercado", 2016, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Celeste Luis Soriano", 2016, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Camille Marie Torres", 2016, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Marie Santiago", 2016, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Adrian Anne Torres", 2016, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joy Angel Fernandez", 2016, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Grace Villanueva", 2016, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Enzo Grace Perez", 2016, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Alyssa Angel Rosales", 2016, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Rose Dela Cruz", 2017, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kyla Rose Torres", 2017, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Amara Rose Mercado", 2017, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samantha Angel Torres", 2017, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Vincent Paolo Flores", 2017, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Marie Morales", 2017, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Marie Tan", 2017, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Antonio Torres", 2017, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Vincent Antonio Cruz", 2017, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Luis Grace Tan", 2017, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Rose Dominguez", 2018, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Camille Luis Tan", 2018, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Gabriel Grace Soriano", 2018, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nathaniel Rose Silva", 2018, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Luis Torres", 2018, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nico Maria Bautista", 2018, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Paolo Cruz", 2018, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Renzo Marie Torres", 2018, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Luis Ortega", 2018, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Rose Torres", 2018, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bianca Luis Velasco", 2019, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Darren Anne Villanueva", 2019, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nico Angel Silva", 2019, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Maria Anne Perez", 2019, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mark Marie Lim", 2019, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Paolo Torres", 2019, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samantha Angel Panganiban", 2019, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rafael Anne Rosales", 2019, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nicole Angel Bautista", 2019, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Rose Mendoza", 2019, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jason Marie Valdez", 2020, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Antonio Navarro", 2020, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Denise Rose Navarro", 2020, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nicole Luis Valdez", 2020, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jade Marie Santiago", 2020, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Jose Silva", 2020, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Rose Silva", 2020, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Noah Angel Garcia", 2020, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Anne Fernandez", 2020, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Vincent Marie Silva", 2020, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Grace Soriano", 2021, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Renzo Angel Tan", 2021, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Joshua Angel Uy", 2021, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Rose Gutierrez", 2021, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Darren Jose Cruz", 2021, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Grace Rivera", 2021, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Hazel Rose Santos", 2021, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Jason Antonio Navarro", 2021, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Marie Fernandez", 2021, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Enzo Angel Gomez", 2021, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Chloe Paolo Santiago", 2022, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Adrian Jose Aquino", 2022, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Juan Luis Magsaysay", 2022, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Nico Anne Dela Cruz", 2022, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Bryan Jose Tan", 2022, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Jose Sanchez", 2022, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Kristine Marie Aquino", 2022, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Miguel Angel Villanueva", 2022, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Maria Villanueva", 2022, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Christian Paolo Martinez", 2022, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Marco Paolo Uy", 2023, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Rose Cruz", 2023, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ivan Maria Flores", 2023, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Camille Rose Garcia", 2023, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Paolo Jose Dizon", 2023, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Erika Angel Ortega", 2023, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mia Paolo Ramos", 2023, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Caleb Antonio Aquino", 2023, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Luis Navarro", 2023, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rina Rose Navarro", 2023, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Maria Dela Cruz", 2024, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Paolo Cruz", 2024, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Antonio Ortega", 2024, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Trisha Antonio Aquino", 2024, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Lara Anne Dizon", 2024, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Julian Rose Cruz", 2024, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Anne Torres", 2024, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Diego Paolo Rivera", 2024, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Vincent Maria Uy", 2024, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Maria Rose Magsaysay", 2024, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rafael Rose Lopez", 2025, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Mika Rose Silva", 2025, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patrick Grace De Leon", 2025, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ana Luis Morales", 2025, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Andre Grace Castillo", 2025, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Rhea Antonio Gutierrez", 2025, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Ethan Anne Martinez", 2025, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Erika Angel De Leon", 2025, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Hazel Jose Fernandez", 2025, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Enzo Maria Garcia", 2025, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Sofia Angel Reyes", 2026, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Rose Velasco", 2026, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Angela Anne Santiago", 2026, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Clarisse Anne Panganiban", 2026, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Patricia Paolo Dizon", 2026, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Samuel Paolo Flores", 2026, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Monique Antonio Villanueva", 2026, c.id, "3rd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="3rd Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Trisha Jose De Leon", 2026, c.id, "4th Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="4th Year"
WHERE c.code="BSIT" AND s.name="Section B";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Francis Angel Santiago", 2026, c.id, "1st Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="1st Year"
WHERE c.code="BSIT" AND s.name="Section A";

INSERT OR IGNORE INTO students (student_name, enrollment_year, course_id, year_level, section_id, email, email_verified, student_status, is_sample)
SELECT "Erika Marie Martinez", 2026, c.id, "2nd Year", s.id, NULL, 0, "SAMPLE", 1
FROM courses c JOIN sections s ON s.course_id=c.id JOIN year_levels y ON y.id=s.year_level_id AND y.name="2nd Year"
WHERE c.code="BSIT" AND s.name="Section B";

CREATE INDEX IF NOT EXISTS students_enrollment_year_idx ON students(enrollment_year);
CREATE INDEX IF NOT EXISTS students_course_idx ON students(course_id);
CREATE INDEX IF NOT EXISTS students_year_level_idx ON students(year_level);
CREATE INDEX IF NOT EXISTS students_section_idx ON students(section_id);
CREATE INDEX IF NOT EXISTS students_name_idx ON students(student_name);
CREATE INDEX IF NOT EXISTS students_email_idx ON students(email);
CREATE INDEX IF NOT EXISTS test_recipients_email_idx ON test_recipients(email);
