<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    header('Allow: GET');
    http_response_code(405);
    exit('Method not allowed.');
}
if (!isset($_SESSION['user_id']) || !is_osa_admin($db)) {
    http_response_code(401);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => false, 'message' => 'Please log in to the OSA Admin account.'], JSON_THROW_ON_ERROR);
    exit;
}

require_once __DIR__ . '/announcement-recipient-common.php';

$batch = filter_var($_GET['batch'] ?? null, FILTER_VALIDATE_INT);
$courseId = filter_var($_GET['course_id'] ?? null, FILTER_VALIDATE_INT);
$sectionId = filter_var($_GET['section_id'] ?? null, FILTER_VALIDATE_INT);
$yearLevel = trim(is_string($_GET['year_level'] ?? null) ? $_GET['year_level'] : '');
$search = trim(is_string($_GET['search'] ?? null) ? $_GET['search'] : '');
$search = substr($search, 0, 100);

if ($batch === false || $batch < 1
    || $courseId === false || $courseId < 1
    || $sectionId === false || $sectionId < 1
    || $yearLevel === '' || strlen($yearLevel) > 100) {
    http_response_code(422);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => false, 'message' => 'Invalid student filters.'], JSON_THROW_ON_ERROR);
    exit;
}

$stmt = $db->prepare('
    SELECT s.id, s.student_name, s.enrollment_year, s.year_level,
           s.email, s.student_status, s.is_sample,
           c.code AS course_code, sec.name AS section_name
    FROM students s
    JOIN courses c ON c.id = s.course_id
    JOIN sections sec ON sec.id = s.section_id
    WHERE s.enrollment_year = :batch
      AND s.course_id = :course_id
      AND s.year_level = :year_level
      AND s.section_id = :section_id
      AND (:search = "" OR s.student_name LIKE :search_like)
    ORDER BY s.student_name ASC
');
$stmt->execute([
    ':batch' => $batch,
    ':course_id' => $courseId,
    ':year_level' => $yearLevel,
    ':section_id' => $sectionId,
    ':search' => $search,
    ':search_like' => '%' . $search . '%',
]);
$students = array_map(static function (array $student): array {
    $email = trim(is_string($student['email'] ?? null) ? $student['email'] : '');
    return [
        'id' => (int) $student['id'],
        'student_name' => $student['student_name'],
        'course_code' => $student['course_code'],
        'section_name' => $student['section_name'],
        'has_valid_email' => $email !== '' && filter_var($email, FILTER_VALIDATE_EMAIL) !== false,
        'eligible_for_announcement' => announcement_student_is_eligible($student),
    ];
}, $stmt->fetchAll());

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');
echo json_encode(['ok' => true, 'students' => $students], JSON_THROW_ON_ERROR);
