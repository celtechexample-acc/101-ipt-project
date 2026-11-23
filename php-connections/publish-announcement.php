<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/announcement-recipient-common.php';
require_once __DIR__ . '/mailer.php';

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');

function announcement_json_response(array $payload, int $status = 200): never
{
    http_response_code($status);
    echo json_encode($payload, JSON_THROW_ON_ERROR);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Allow: POST');
    announcement_json_response(['ok' => false, 'message' => 'Method not allowed.'], 405);
}
if (!isset($_SESSION['user_id'])) {
    announcement_json_response(['ok' => false, 'message' => 'Please log in.'], 401);
}
$sessionStmt = $db->prepare('SELECT session_version FROM users WHERE id = :id');
$sessionStmt->execute([':id' => (int) $_SESSION['user_id']]);
$sessionVersion = $sessionStmt->fetchColumn();
if ($sessionVersion === false || (int) $sessionVersion !== (int) ($_SESSION['session_version'] ?? 0)) {
    $_SESSION = [];
    session_destroy();
    announcement_json_response(['ok' => false, 'message' => 'Your login session has expired. Please log in again.'], 401);
}
if (!csrf_token_is_valid()) {
    announcement_json_response(['ok' => false, 'message' => 'Your session expired. Refresh the dashboard and try again.'], 400);
}
if (($_POST['action'] ?? null) !== 'publish' || isset($_POST['office_confirmation']) || isset($_POST['director_approval'])) {
    announcement_json_response(['ok' => false, 'message' => 'Student emails are sent only when an announcement is actually published after approvals.'], 409);
}

$title = trim(is_string($_POST['title'] ?? null) ? $_POST['title'] : '');
$details = trim(is_string($_POST['details'] ?? null) ? $_POST['details'] : '');
$date = is_string($_POST['date'] ?? null) ? $_POST['date'] : '';
$audienceJson = is_string($_POST['audience'] ?? null) ? $_POST['audience'] : '';
if ($title === '' || strlen($title) > 200 || $details === '' || strlen($details) > 50000) {
    announcement_json_response(['ok' => false, 'message' => 'Enter an announcement title and details within the allowed length.'], 422);
}
$publishDate = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
if ($publishDate === false || $publishDate->format('Y-m-d') !== $date || $date < date('Y-m-d')) {
    announcement_json_response(['ok' => false, 'message' => 'Choose a valid publish date that is today or later.'], 422);
}

try {
    $audience = json_decode($audienceJson, true, 16, JSON_THROW_ON_ERROR);
} catch (JsonException) {
    announcement_json_response(['ok' => false, 'message' => 'Confirm the recipient selection before publishing.'], 422);
}
if (!is_array($audience) || !is_string($audience['mode'] ?? null)) {
    announcement_json_response(['ok' => false, 'message' => 'Confirm the recipient selection before publishing.'], 422);
}

if ($audience['mode'] === 'all_active') {
    $students = announcement_fetch_active_students($db);
} elseif ($audience['mode'] === 'selective') {
    $studentIds = $audience['student_ids'] ?? null;
    $batch = filter_var($audience['batch'] ?? null, FILTER_VALIDATE_INT);
    $courseId = filter_var($audience['course_id'] ?? null, FILTER_VALIDATE_INT);
    $sectionId = filter_var($audience['section_id'] ?? null, FILTER_VALIDATE_INT);
    $yearLevel = is_string($audience['year_level'] ?? null) ? $audience['year_level'] : '';
    if (!is_array($studentIds) || $studentIds === [] || count($studentIds) > 10000
        || $batch === false || $batch < 1 || $courseId === false || $courseId < 1
        || $sectionId === false || $sectionId < 1 || $yearLevel === '' || strlen($yearLevel) > 100) {
        announcement_json_response(['ok' => false, 'message' => 'Select eligible students before publishing.'], 422);
    }

    $validatedIds = [];
    foreach ($studentIds as $studentId) {
        $validatedId = filter_var($studentId, FILTER_VALIDATE_INT);
        if ($validatedId === false || $validatedId < 1 || isset($validatedIds[$validatedId])) {
            announcement_json_response(['ok' => false, 'message' => 'The selected student list is invalid. Review the recipients and try again.'], 422);
        }
        $validatedIds[$validatedId] = $validatedId;
    }

    $students = announcement_fetch_students($db, array_values($validatedIds));
    if (count($students) !== count($validatedIds)) {
        announcement_json_response(['ok' => false, 'message' => 'One or more selected student records are no longer available. Review the recipients and try again.'], 422);
    }
    foreach ($students as $student) {
        if ((int) $student['enrollment_year'] !== $batch
            || (int) $student['course_id'] !== $courseId
            || (int) $student['section_id'] !== $sectionId
            || $student['year_level'] !== $yearLevel
            || $student['course_code'] === null
            || $student['section_name'] === null) {
            announcement_json_response(['ok' => false, 'message' => 'The selected students do not match the confirmed batch, course, year level, and section. Review the recipients and try again.'], 422);
        }
    }

    $sectionStmt = $db->prepare('
        SELECT COUNT(*)
        FROM sections sec
        JOIN year_levels y ON y.id = sec.year_level_id
        WHERE sec.id = :section_id
          AND sec.course_id = :course_id
          AND y.name = :year_level
    ');
    $sectionStmt->execute([
        ':section_id' => $sectionId,
        ':course_id' => $courseId,
        ':year_level' => $yearLevel,
    ]);
    if ((int) $sectionStmt->fetchColumn() !== 1) {
        announcement_json_response(['ok' => false, 'message' => 'The selected course, year level, or section relationship is invalid.'], 422);
    }
} else {
    announcement_json_response(['ok' => false, 'message' => 'Choose a valid recipient mode.'], 422);
}

$summary = announcement_recipient_summary($students);
$recipients = $summary['recipients'];
if ($recipients === []) {
    announcement_json_response([
        'ok' => false,
        'message' => 'There are no eligible students with valid email addresses in this selection.',
        'excluded_count' => $summary['excluded_count'],
    ], 422);
}

$sentCount = 0;
$failedCount = 0;
foreach ($recipients as $recipient) {
    try {
        send_announcement_email($recipient['email'], $title, $details);
        $sentCount++;
    } catch (\PHPMailer\PHPMailer\Exception | RuntimeException $error) {
        error_log('Announcement email delivery failed for a recipient.');
        $failedCount++;
    }
}

if ($failedCount > 0) {
    announcement_json_response([
        'ok' => false,
        'message' => 'Announcement delivery was incomplete. Some email addresses could not be reached.',
        'sent_count' => $sentCount,
        'failed_count' => $failedCount,
        'excluded_count' => $summary['excluded_count'],
    ], 502);
}

announcement_json_response([
    'ok' => true,
    'sent_count' => $sentCount,
    'excluded_count' => $summary['excluded_count'],
]);
