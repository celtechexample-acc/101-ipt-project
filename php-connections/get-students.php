<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    header('Allow: GET');
    http_response_code(405);
    exit('Method not allowed.');
}
if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => false, 'message' => 'Please log in.'], JSON_THROW_ON_ERROR);
    exit;
}

$batch = filter_var($_GET['batch'] ?? null, FILTER_VALIDATE_INT);
$courseId = filter_var($_GET['course_id'] ?? null, FILTER_VALIDATE_INT);
$sectionId = filter_var($_GET['section_id'] ?? null, FILTER_VALIDATE_INT);
$yearLevel = trim(is_string($_GET['year_level'] ?? null) ? $_GET['year_level'] : '');
$search = trim(is_string($_GET['search'] ?? null) ? $_GET['search'] : '');
$search = substr($search, 0, 100);

if ($batch === false || $batch < 1959 || $batch > 2026
    || $courseId === false || $courseId < 1
    || $sectionId === false || $sectionId < 1
    || !in_array($yearLevel, ['1st Year', '2nd Year', '3rd Year', '4th Year'], true)) {
    http_response_code(422);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => false, 'message' => 'Invalid student filters.'], JSON_THROW_ON_ERROR);
    exit;
}

$stmt = $db->prepare('
    SELECT
        s.id,
        s.student_name,
        s.enrollment_year,
        s.year_level,
        s.email,
        s.email_verified,
        s.student_status,
        s.is_sample,
        c.code AS course_code,
        c.name AS course_name,
        sec.name AS section_name
    FROM students s
    JOIN courses c ON c.id = s.course_id
    JOIN sections sec ON sec.id = s.section_id
    WHERE s.enrollment_year = :batch
      AND s.course_id = :course_id
      AND s.year_level = :year_level
      AND s.section_id = :section_id
      AND (:search = "" OR s.student_name LIKE :search_like OR CAST(s.id AS TEXT) LIKE :search_like)
    ORDER BY s.student_name ASC
    LIMIT 500
');
$stmt->execute([
    ':batch' => $batch,
    ':course_id' => $courseId,
    ':year_level' => $yearLevel,
    ':section_id' => $sectionId,
    ':search' => $search,
    ':search_like' => '%' . $search . '%',
]);
$students = $stmt->fetchAll();

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');
echo json_encode(['ok' => true, 'students' => $students], JSON_THROW_ON_ERROR);
