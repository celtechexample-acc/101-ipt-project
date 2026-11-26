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

$kind = is_string($_GET['kind'] ?? null) ? $_GET['kind'] : '';
$allowedKinds = ['courses', 'year_levels', 'sections', 'active_summary'];
if (!in_array($kind, $allowedKinds, true)) {
    http_response_code(422);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => false, 'message' => 'Invalid audience option type.'], JSON_THROW_ON_ERROR);
    exit;
}

$options = [];
if ($kind === 'active_summary') {
    $activeStudents = announcement_fetch_active_students($db);
    $summary = announcement_recipient_summary($activeStudents);
    $options = [
        'eligible_count' => count($summary['recipients']),
        'active_student_count' => count($activeStudents),
        'excluded_count' => $summary['excluded_count'],
    ];
} elseif ($kind === 'courses') {
    $batchRaw = is_string($_GET['batch'] ?? null) ? trim($_GET['batch']) : '';
    $batch = $batchRaw === '' ? null : filter_var($batchRaw, FILTER_VALIDATE_INT);
    if ($batch !== null && ($batch === false || $batch < 1)) {
        http_response_code(422);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['ok' => false, 'message' => 'Select a valid batch year.'], JSON_THROW_ON_ERROR);
        exit;
    }

    $stmt = $db->prepare('
        SELECT DISTINCT c.id, c.code, c.name
        FROM students s
        JOIN courses c ON c.id = s.course_id
        WHERE (:batch IS NULL OR s.enrollment_year = :batch)
        ORDER BY c.code ASC
    ');
    $stmt->execute([':batch' => $batch]);
    $options = $stmt->fetchAll();
} elseif ($kind === 'year_levels') {
    $batchRaw = is_string($_GET['batch'] ?? null) ? trim($_GET['batch']) : '';
    $batch = $batchRaw === '' ? null : filter_var($batchRaw, FILTER_VALIDATE_INT);
    $courseId = filter_var($_GET['course_id'] ?? null, FILTER_VALIDATE_INT);
    if (($batch !== null && ($batch === false || $batch < 1)) || $courseId === false || $courseId < 1) {
        http_response_code(422);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['ok' => false, 'message' => 'Select a valid batch year and course.'], JSON_THROW_ON_ERROR);
        exit;
    }

    $stmt = $db->prepare('
        SELECT DISTINCT s.year_level AS name
        FROM students s
        JOIN courses c ON c.id = s.course_id
        WHERE (:batch IS NULL OR s.enrollment_year = :batch)
          AND s.course_id = :course_id
        ORDER BY s.year_level ASC
    ');
    $stmt->execute([
        ':batch' => $batch,
        ':course_id' => $courseId,
    ]);
    $options = $stmt->fetchAll();
} else {
    $batchRaw = is_string($_GET['batch'] ?? null) ? trim($_GET['batch']) : '';
    $batch = $batchRaw === '' ? null : filter_var($batchRaw, FILTER_VALIDATE_INT);
    $courseId = filter_var($_GET['course_id'] ?? null, FILTER_VALIDATE_INT);
    $yearLevel = trim(is_string($_GET['year_level'] ?? null) ? $_GET['year_level'] : '');
    if (($batch !== null && ($batch === false || $batch < 1))
        || $courseId === false || $courseId < 1 || $yearLevel === '') {
        http_response_code(422);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['ok' => false, 'message' => 'Select a valid batch, course, and year level.'], JSON_THROW_ON_ERROR);
        exit;
    }

    $stmt = $db->prepare('
        SELECT DISTINCT sec.id, sec.name
        FROM students s
        JOIN courses c ON c.id = s.course_id
        JOIN sections sec ON sec.id = s.section_id
        WHERE (:batch IS NULL OR s.enrollment_year = :batch)
          AND s.course_id = :course_id
          AND s.year_level = :year_level
        ORDER BY sec.name ASC
    ');
    $stmt->execute([
        ':batch' => $batch,
        ':course_id' => $courseId,
        ':year_level' => $yearLevel,
    ]);
    $options = $stmt->fetchAll();
}

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');
echo json_encode(
    $kind === 'active_summary'
        ? ['ok' => true, 'summary' => $options]
        : ['ok' => true, 'options' => $options],
    JSON_THROW_ON_ERROR
);
