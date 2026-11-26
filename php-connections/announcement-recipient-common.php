<?php
declare(strict_types=1);

const ANNOUNCEMENT_TEST_STUDENT_IDS = [48961, 86363];

function announcement_student_is_eligible(array $student): bool
{
    $studentId = filter_var($student['id'] ?? null, FILTER_VALIDATE_INT);
    $isSample = (int) ($student['is_sample'] ?? 1) === 1;
    $status = strtoupper(trim((string) ($student['student_status'] ?? '')));

    if ($isSample) {
        return $studentId !== false && in_array($studentId, ANNOUNCEMENT_TEST_STUDENT_IDS, true);
    }

    return in_array($status, ['ACTIVE', 'ENROLLED'], true);
}

function announcement_fetch_active_students(PDO $db, ?array $studentIds = null): array
{
    $sql = '
        SELECT s.id, s.student_name, s.enrollment_year, s.course_id, s.year_level,
               s.section_id, s.email, s.student_status, s.is_sample,
               c.code AS course_code, c.name AS course_name,
               sec.name AS section_name
        FROM students s
        LEFT JOIN courses c ON c.id = s.course_id
        LEFT JOIN sections sec ON sec.id = s.section_id
        WHERE (
            (UPPER(TRIM(s.student_status)) IN (\'ACTIVE\', \'ENROLLED\') AND s.is_sample = 0)
            OR s.id IN (' . implode(', ', ANNOUNCEMENT_TEST_STUDENT_IDS) . ')
        )
    ';
    $parameters = [];

    if ($studentIds !== null) {
        if ($studentIds === []) {
            return [];
        }

        $placeholders = [];
        foreach (array_values($studentIds) as $index => $studentId) {
            $placeholder = ':student_id_' . $index;
            $placeholders[] = $placeholder;
            $parameters[$placeholder] = $studentId;
        }
        $sql .= ' AND s.id IN (' . implode(', ', $placeholders) . ')';
    }

    $sql .= ' ORDER BY s.student_name COLLATE NOCASE ASC, s.id ASC';
    $stmt = $db->prepare($sql);
    $stmt->execute($parameters);

    return $stmt->fetchAll();
}

function announcement_fetch_students(PDO $db, array $studentIds): array
{
    if ($studentIds === []) {
        return [];
    }

    $placeholders = [];
    $parameters = [];
    foreach (array_values($studentIds) as $index => $studentId) {
        $placeholder = ':student_id_' . $index;
        $placeholders[] = $placeholder;
        $parameters[$placeholder] = $studentId;
    }

    $stmt = $db->prepare('
        SELECT s.id, s.student_name, s.enrollment_year, s.course_id, s.year_level,
               s.section_id, s.email, s.student_status, s.is_sample,
               c.code AS course_code, c.name AS course_name,
               sec.name AS section_name
        FROM students s
        LEFT JOIN courses c ON c.id = s.course_id
        LEFT JOIN sections sec ON sec.id = s.section_id
        WHERE s.id IN (' . implode(', ', $placeholders) . ')
        ORDER BY s.student_name COLLATE NOCASE ASC, s.id ASC
    ');
    $stmt->execute($parameters);

    return $stmt->fetchAll();
}

function announcement_recipient_summary(array $students): array
{
    $recipients = [];
    $seenEmails = [];
    $invalidEmailCount = 0;
    $duplicateEmailCount = 0;

    foreach ($students as $student) {
        $email = trim(is_string($student['email'] ?? null) ? $student['email'] : '');
        if ($email === '' || filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
            $invalidEmailCount++;
            continue;
        }

        $emailKey = strtolower($email);
        if (isset($seenEmails[$emailKey])) {
            $duplicateEmailCount++;
            continue;
        }

        $seenEmails[$emailKey] = true;
        $student['email'] = $email;
        $recipients[] = $student;
    }

    return [
        'recipients' => $recipients,
        'invalid_email_count' => $invalidEmailCount,
        'duplicate_email_count' => $duplicateEmailCount,
        'excluded_count' => $invalidEmailCount + $duplicateEmailCount,
    ];
}
