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

$kind = is_string($_GET['kind'] ?? null) ? $_GET['kind'] : '';
$allowedKinds = ['year_levels', 'courses', 'sections'];
if (!in_array($kind, $allowedKinds, true)) {
    http_response_code(422);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => false, 'message' => 'Invalid audience option type.'], JSON_THROW_ON_ERROR);
    exit;
}

$options = [];
if ($kind === 'year_levels') {
    $options = $db->query('
        SELECT id, name
        FROM year_levels
        ORDER BY sort_order ASC
    ')->fetchAll();
} elseif ($kind === 'courses') {
    $options = $db->query('
        SELECT id, code, name
        FROM courses
        WHERE is_active = 1
        ORDER BY code ASC
    ')->fetchAll();
} else {
    $courseId = filter_var($_GET['course_id'] ?? null, FILTER_VALIDATE_INT);
    $yearLevelId = filter_var($_GET['year_level_id'] ?? null, FILTER_VALIDATE_INT);
    if ($courseId === false || $courseId < 1 || $yearLevelId === false || $yearLevelId < 1) {
        http_response_code(422);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['ok' => false, 'message' => 'Select a valid course and year level.'], JSON_THROW_ON_ERROR);
        exit;
    }

    $stmt = $db->prepare('
        SELECT s.id, s.name
        FROM sections s
        JOIN courses c ON c.id = s.course_id
        WHERE s.is_active = 1
          AND s.course_id = :course_id
          AND s.year_level_id = :year_level_id
        ORDER BY s.name ASC
    ');
    $stmt->execute([
        ':course_id' => $courseId,
        ':year_level_id' => $yearLevelId,
    ]);
    $options = $stmt->fetchAll();
}

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');
echo json_encode(['ok' => true, 'options' => $options], JSON_THROW_ON_ERROR);
