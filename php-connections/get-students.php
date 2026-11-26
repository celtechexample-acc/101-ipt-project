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

$batchRaw = is_string($_GET['batch'] ?? null) ? trim($_GET['batch']) : '';
$courseRaw = is_string($_GET['course_id'] ?? null) ? trim($_GET['course_id']) : '';
$sectionRaw = is_string($_GET['section_id'] ?? null) ? trim($_GET['section_id']) : '';
$batch = $batchRaw === '' ? null : filter_var($batchRaw, FILTER_VALIDATE_INT);
$courseId = $courseRaw === '' ? null : filter_var($courseRaw, FILTER_VALIDATE_INT);
$sectionId = $sectionRaw === '' ? null : filter_var($sectionRaw, FILTER_VALIDATE_INT);
$yearLevel = trim(is_string($_GET['year_level'] ?? null) ? $_GET['year_level'] : '');
$search = trim(is_string($_GET['search'] ?? null) ? $_GET['search'] : '');
$search = substr($search, 0, 100);
$eligibleOnly = ($_GET['eligible_only'] ?? '') === '1';

if (($batch !== null && ($batch === false || $batch < 1))
    || ($courseId !== null && ($courseId === false || $courseId < 1))
    || ($sectionId !== null && ($sectionId === false || $sectionId < 1))
    || strlen($yearLevel) > 100) {
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
    LEFT JOIN courses c ON c.id = s.course_id
    LEFT JOIN sections sec ON sec.id = s.section_id
    WHERE (:batch IS NULL OR s.enrollment_year = :batch)
      AND (:course_id IS NULL OR s.course_id = :course_id)
      AND (:year_level = "" OR s.year_level = :year_level)
      AND (:section_id IS NULL OR s.section_id = :section_id)
      AND (:search = "" OR s.student_name LIKE :search_like OR CAST(s.id AS TEXT) LIKE :search_like)
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
        'enrollment_year' => (int) $student['enrollment_year'],
        'year_level' => $student['year_level'],
        'course_code' => $student['course_code'],
        'section_name' => $student['section_name'],
        'email' => $email,
        'has_valid_email' => $email !== '' && filter_var($email, FILTER_VALIDATE_EMAIL) !== false,
        'eligible_for_announcement' => announcement_student_is_eligible($student),
    ];
}, $stmt->fetchAll());
if ($eligibleOnly) {
    $students = array_values(array_filter(
        $students,
        static fn(array $student): bool => $student['eligible_for_announcement']
    ));
}

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');
echo json_encode(['ok' => true, 'students' => $students], JSON_THROW_ON_ERROR);
