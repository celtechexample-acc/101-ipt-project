<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/announcement-recipient-common.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    header('Allow: GET');
    http_response_code(405);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => false, 'message' => 'Method not allowed.'], JSON_THROW_ON_ERROR);
    exit;
}
if (!isset($_SESSION['user_id']) || !is_osa_admin($db)) {
    http_response_code(401);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => false, 'message' => 'Please log in to the OSA Admin account.'], JSON_THROW_ON_ERROR);
    exit;
}

$query = trim(is_string($_GET['q'] ?? null) ? $_GET['q'] : '');
$query = substr($query, 0, 100);
if (strlen($query) < 2) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => true, 'suggestions' => []], JSON_THROW_ON_ERROR);
    exit;
}
$like = '%' . str_replace(['%', '_'], ['\\%', '\\_'], $query) . '%';

$suggestions = [];

$batchStmt = $db->prepare('
    SELECT DISTINCT enrollment_year AS value
    FROM students
    WHERE CAST(enrollment_year AS TEXT) LIKE :like ESCAPE "\\"
    ORDER BY enrollment_year DESC
    LIMIT 8
');
$batchStmt->execute([':like' => $like]);
foreach ($batchStmt->fetchAll() as $row) {
    $suggestions[] = [
        'category' => 'Batch',
        'id' => (int) $row['value'],
        'label' => (string) $row['value'],
        'detail' => 'Enrollment year',
        'eligible' => true,
    ];
}

$courseStmt = $db->prepare('
    SELECT id, code, name
    FROM courses
    WHERE code LIKE :like ESCAPE "\\" OR name LIKE :like ESCAPE "\\"
    ORDER BY code ASC
    LIMIT 8
');
$courseStmt->execute([':like' => $like]);
foreach ($courseStmt->fetchAll() as $row) {
    $suggestions[] = [
        'category' => 'Course',
        'id' => (int) $row['id'],
        'label' => (string) $row['code'],
        'detail' => (string) $row['name'],
        'eligible' => true,
    ];
}

$yearStmt = $db->prepare('
    SELECT DISTINCT name
    FROM year_levels
    WHERE name LIKE :like ESCAPE "\\"
    ORDER BY sort_order ASC
    LIMIT 8
');
$yearStmt->execute([':like' => $like]);
foreach ($yearStmt->fetchAll() as $row) {
    $suggestions[] = [
        'category' => 'Year Level',
        'id' => $row['name'],
        'label' => (string) $row['name'],
        'detail' => 'Grade / year level',
        'eligible' => true,
    ];
}

$sectionStmt = $db->prepare('
    SELECT sec.id, sec.name, c.code AS course_code, y.name AS year_level
    FROM sections sec
    JOIN courses c ON c.id = sec.course_id
    JOIN year_levels y ON y.id = sec.year_level_id
    WHERE sec.name LIKE :like ESCAPE "\\" OR c.code LIKE :like ESCAPE "\\" OR y.name LIKE :like ESCAPE "\\"
    ORDER BY sec.name ASC
    LIMIT 8
');
$sectionStmt->execute([':like' => $like]);
foreach ($sectionStmt->fetchAll() as $row) {
    $suggestions[] = [
        'category' => 'Section',
        'id' => (int) $row['id'],
        'label' => (string) $row['name'],
        'detail' => $row['course_code'] . ' · ' . $row['year_level'],
        'eligible' => true,
    ];
}

$studentStmt = $db->prepare('
    SELECT s.id, s.student_name, s.enrollment_year, s.course_id, s.year_level,
           s.section_id, s.email, s.student_status, s.is_sample,
           c.code AS course_code, sec.name AS section_name
    FROM students s
    LEFT JOIN courses c ON c.id = s.course_id
    LEFT JOIN sections sec ON sec.id = s.section_id
    WHERE s.student_name LIKE :like ESCAPE "\\" OR CAST(s.id AS TEXT) LIKE :like ESCAPE "\\"
    ORDER BY s.student_name COLLATE NOCASE ASC
    LIMIT 10
');
$studentStmt->execute([':like' => $like]);
foreach ($studentStmt->fetchAll() as $row) {
    $eligible = announcement_student_is_eligible($row);
    $email = trim(is_string($row['email'] ?? null) ? $row['email'] : '');
    $eligible = $eligible && $email !== '' && filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    $suggestions[] = [
        'category' => 'Student',
        'id' => (int) $row['id'],
        'label' => (string) $row['student_name'],
        'detail' => 'ID ' . $row['id'] . ' · Batch ' . $row['enrollment_year'] .
            ' · ' . ($row['course_code'] ?: 'No course') . ' · ' . ($row['section_name'] ?: 'No section'),
        'eligible' => $eligible,
        'reason' => $eligible ? '' : 'Ineligible or no valid email',
    ];
}

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');
echo json_encode(['ok' => true, 'suggestions' => $suggestions], JSON_THROW_ON_ERROR);
