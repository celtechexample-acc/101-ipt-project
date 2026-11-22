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

$search = trim(is_string($_GET['search'] ?? null) ? $_GET['search'] : '');
$search = substr($search, 0, 4);
$stmt = $db->prepare('
    SELECT DISTINCT enrollment_year
    FROM students
    WHERE enrollment_year BETWEEN 1959 AND 2026
      AND (:search = "" OR CAST(enrollment_year AS TEXT) LIKE :search_like)
    ORDER BY enrollment_year DESC
');
$stmt->execute([
    ':search' => $search,
    ':search_like' => '%' . $search . '%',
]);
$years = array_map(
    static fn(array $row): int => (int) $row['enrollment_year'],
    $stmt->fetchAll()
);

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');
echo json_encode(['ok' => true, 'batches' => $years], JSON_THROW_ON_ERROR);
