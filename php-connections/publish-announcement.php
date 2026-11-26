<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/announcement-recipient-common.php';
require_once __DIR__ . '/mailer.php';

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');

function announcement_publish_response(array $payload, int $status = 200): never
{
    http_response_code($status);
    echo json_encode($payload, JSON_THROW_ON_ERROR);
    exit;
}

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    header('Allow: POST');
    announcement_publish_response(['ok' => false, 'message' => 'Method not allowed.'], 405);
}
if (!isset($_SESSION['user_id']) || !is_osa_admin($db)) {
    announcement_publish_response(['ok' => false, 'message' => 'Please log in to the OSA Admin account.'], 401);
}
if (!csrf_token_is_valid()) {
    announcement_publish_response(['ok' => false, 'message' => 'Your session expired. Refresh the dashboard and try again.'], 400);
}
if (($_POST['action'] ?? null) !== 'publish') {
    announcement_publish_response(['ok' => false, 'message' => 'Invalid announcement action.'], 422);
}

$adminId = (int) $_SESSION['user_id'];
$title = trim(is_string($_POST['title'] ?? null) ? $_POST['title'] : '');
$details = trim(is_string($_POST['details'] ?? null) ? $_POST['details'] : '');
$date = is_string($_POST['date'] ?? null) ? $_POST['date'] : '';
$audienceJson = is_string($_POST['audience'] ?? null) ? $_POST['audience'] : '';
$announcementId = trim(is_string($_POST['announcement_id'] ?? null) ? $_POST['announcement_id'] : '');
$requestId = is_string($_POST['publish_request_id'] ?? null) ? $_POST['publish_request_id'] : '';

if ($title === '' || strlen($title) > 200 || preg_match('/[\r\n\x00]/', $title)
    || $details === '' || strlen($details) > 50000) {
    announcement_publish_response(['ok' => false, 'message' => 'Enter a title (up to 200 characters) and details (up to 50,000 characters).'], 422);
}
if ($date === '' || !preg_match('/^[a-f0-9]{32}$/', $requestId)
    || ($announcementId !== '' && !preg_match('/^[a-f0-9]{32}$/', $announcementId))) {
    announcement_publish_response(['ok' => false, 'message' => 'Complete the publish date and refresh the form before publishing.'], 422);
}
$publishDate = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
$today = (new DateTimeImmutable(
    'now',
    new DateTimeZone('Asia/Manila')
))->format('Y-m-d');

if ($publishDate === false || $publishDate->format('Y-m-d') !== $date || $date !== $today) {
    announcement_publish_response([
        'ok' => false,
        'message' => 'Publishing sends email immediately. Choose today\'s date to continue.'
    ], 422);
}

try {
    $audience = json_decode($audienceJson, true, 16, JSON_THROW_ON_ERROR);
} catch (JsonException) {
    announcement_publish_response(['ok' => false, 'message' => 'Confirm the recipient selection before publishing.'], 422);
}
if (!is_array($audience) || !is_string($audience['mode'] ?? null)) {
    announcement_publish_response(['ok' => false, 'message' => 'Confirm the recipient selection before publishing.'], 422);
}

if ($audience['mode'] === 'all_active') {
    $students = announcement_fetch_active_students($db);
} elseif ($audience['mode'] === 'selective') {
    $studentIds = $audience['student_ids'] ?? null;
    $hasHierarchy = array_key_exists('batch', $audience)
        || array_key_exists('course_id', $audience)
        || array_key_exists('section_id', $audience)
        || array_key_exists('year_level', $audience);
    $batch = null;
    $courseId = null;
    $sectionId = null;
    $yearLevel = null;
    if ($hasHierarchy) {
        $batch = filter_var($audience['batch'] ?? null, FILTER_VALIDATE_INT);
        $courseId = filter_var($audience['course_id'] ?? null, FILTER_VALIDATE_INT);
        $sectionId = filter_var($audience['section_id'] ?? null, FILTER_VALIDATE_INT);
        $yearLevel = is_string($audience['year_level'] ?? null) ? $audience['year_level'] : '';
    }
    if (!is_array($studentIds) || $studentIds === [] || count($studentIds) > 10000
        || ($hasHierarchy && ($batch === false || $batch < 1 || $courseId === false || $courseId < 1
            || $sectionId === false || $sectionId < 1 || $yearLevel === '' || strlen($yearLevel) > 100))) {
        announcement_publish_response(['ok' => false, 'message' => 'Select eligible students before publishing.'], 422);
    }

    $validatedIds = [];
    foreach ($studentIds as $studentId) {
        if (!is_int($studentId) && !is_string($studentId)) {
            announcement_publish_response(['ok' => false, 'message' => 'The selected student list is invalid. Review the recipients and try again.'], 422);
        }
        $validatedId = filter_var($studentId, FILTER_VALIDATE_INT);
        if ($validatedId === false || $validatedId < 1 || isset($validatedIds[$validatedId])) {
            announcement_publish_response(['ok' => false, 'message' => 'The selected student list is invalid. Review the recipients and try again.'], 422);
        }
        $validatedIds[$validatedId] = $validatedId;
    }

    $students = announcement_fetch_students($db, array_values($validatedIds));
    if (count($students) !== count($validatedIds)) {
        announcement_publish_response(['ok' => false, 'message' => 'One or more selected student records are no longer available. Review the recipients and try again.'], 422);
    }
    foreach ($students as $student) {
        if (!announcement_student_is_eligible($student)) {
            announcement_publish_response(['ok' => false, 'message' => 'Only active/enrolled students and the designated test recipients can receive announcements.'], 422);
        }
        if ($hasHierarchy) {
            if ($student['course_code'] === null || $student['section_name'] === null
                || (int) $student['enrollment_year'] !== $batch
                || (int) $student['course_id'] !== $courseId
                || (int) $student['section_id'] !== $sectionId
                || $student['year_level'] !== $yearLevel) {
                announcement_publish_response(['ok' => false, 'message' => 'The selected students do not match the confirmed, eligible batch, course, year level, and section. Review the recipients and try again.'], 422);
            }
        }
    }

    if ($hasHierarchy) {
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
            announcement_publish_response(['ok' => false, 'message' => 'The selected course, year level, or section relationship is invalid.'], 422);
        }
    }
} else {
    announcement_publish_response(['ok' => false, 'message' => 'Choose a valid recipient mode.'], 422);
}

$summary = announcement_recipient_summary($students);
$recipients = $summary['recipients'];

try {
    begin_sqlite_immediate($db);
    $existingRequest = $db->prepare('
        SELECT id, status, sent_count, failed_count, excluded_count
        FROM announcements
        WHERE publish_request_id = :request_id
        LIMIT 1
    ');
    $existingRequest->execute([':request_id' => $requestId]);
    $existing = $existingRequest->fetch();
    if ($existing !== false) {
        $db->commit();
        $response = [
            'ok' => $existing['status'] === 'published',
            'announcement_id' => $existing['id'],
            'status' => $existing['status'],
            'sent_count' => (int) $existing['sent_count'],
            'failed_count' => (int) $existing['failed_count'],
            'excluded_count' => (int) $existing['excluded_count'],
        ];
        if ($existing['status'] === 'publishing') {
            $response['message'] = 'This publish request is already being processed and will not be sent again.';
            announcement_publish_response($response, 409);
        }
        if ($existing['status'] !== 'published') {
            $response['message'] = 'This publish request has already been processed. Review its delivery results in announcement history.';
        }
        announcement_publish_response($response, $existing['status'] === 'published' ? 200 : 502);
    }

    if ($announcementId !== '') {
        $draftStmt = $db->prepare('
            SELECT 1
            FROM announcements
            WHERE id = :id AND created_by = :created_by AND status = \'draft\'
            LIMIT 1
        ');
        $draftStmt->execute([':id' => $announcementId, ':created_by' => $adminId]);
        if ($draftStmt->fetchColumn() === false) {
            $db->rollBack();
            announcement_publish_response(['ok' => false, 'message' => 'This draft no longer exists or cannot be published. Refresh the draft list.'], 409);
        }
        $stmt = $db->prepare('
            UPDATE announcements
            SET title = :title,
                details = :details,
                audience_json = :audience_json,
                publish_date = :publish_date,
                status = \'publishing\',
                publish_request_id = :request_id,
                sent_count = 0,
                failed_count = 0,
                excluded_count = :excluded_count,
                published_at = NULL,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = :id AND created_by = :created_by AND status = \'draft\'
        ');
        $stmt->execute([
            ':title' => $title,
            ':details' => $details,
            ':audience_json' => $audienceJson,
            ':publish_date' => $date,
            ':request_id' => $requestId,
            ':excluded_count' => $summary['excluded_count'],
            ':id' => $announcementId,
            ':created_by' => $adminId,
        ]);
    } else {
        $announcementId = bin2hex(random_bytes(16));
        $stmt = $db->prepare('
            INSERT INTO announcements
                (id, title, details, audience_json, publish_date, status, created_by,
                 publish_request_id, excluded_count)
            VALUES
                (:id, :title, :details, :audience_json, :publish_date, \'publishing\',
                 :created_by, :request_id, :excluded_count)
        ');
        $stmt->execute([
            ':id' => $announcementId,
            ':title' => $title,
            ':details' => $details,
            ':audience_json' => $audienceJson,
            ':publish_date' => $date,
            ':created_by' => $adminId,
            ':request_id' => $requestId,
            ':excluded_count' => $summary['excluded_count'],
        ]);
    }

    $recipientInsert = $db->prepare('
        INSERT INTO announcement_recipients (announcement_id, student_id, recipient_email)
        VALUES (:announcement_id, :student_id, :recipient_email)
    ');
    foreach ($recipients as $recipient) {
        $recipientInsert->execute([
            ':announcement_id' => $announcementId,
            ':student_id' => (int) $recipient['id'],
            ':recipient_email' => $recipient['email'],
        ]);
    }
    $db->commit();
} catch (Throwable $error) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log('Announcement publish preparation failed: ' . $error->getMessage());
    announcement_publish_response(['ok' => false, 'message' => 'The announcement could not be prepared for delivery. No email was sent.'], 500);
}

$sentCount = 0;
$failedCount = 0;
$recipientUpdate = $db->prepare('
    UPDATE announcement_recipients
    SET delivery_status = :delivery_status,
        delivered_at = CASE WHEN :delivered = 1 THEN CURRENT_TIMESTAMP ELSE NULL END,
        failure_code = :failure_code
    WHERE announcement_id = :announcement_id AND student_id = :student_id
');
try {
    foreach ($recipients as $recipient) {
        $deliveryStatus = 'sent';
        $failureCode = null;
        try {
            send_announcement_email($recipient['email'], $title, $details);
            $sentCount++;
        } catch (\PHPMailer\PHPMailer\Exception | RuntimeException $error) {
            error_log('Announcement email delivery failed (' . get_class($error) . ', code ' . (int) $error->getCode() . ').');
            $failedCount++;
            $deliveryStatus = 'failed';
            $failureCode = 'smtp_error';
        }
        $recipientUpdate->execute([
            ':delivery_status' => $deliveryStatus,
            ':delivered' => $deliveryStatus === 'sent' ? 1 : 0,
            ':failure_code' => $failureCode,
            ':announcement_id' => $announcementId,
            ':student_id' => (int) $recipient['id'],
        ]);
    }

    $status = $failedCount === 0
        ? 'published'
        : ($sentCount > 0 ? 'partial_delivery' : 'delivery_failed');
    $finalize = $db->prepare('
        UPDATE announcements
        SET status = :status,
            sent_count = :sent_count,
            failed_count = :failed_count,
            published_at = CASE WHEN :sent_count > 0 THEN CURRENT_TIMESTAMP ELSE NULL END,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = :id AND created_by = :created_by AND status = \'publishing\'
    ');
    $finalize->execute([
        ':status' => $status,
        ':sent_count' => $sentCount,
        ':failed_count' => $failedCount,
        ':id' => $announcementId,
        ':created_by' => $adminId,
    ]);
    if ($finalize->rowCount() !== 1) {
        throw new RuntimeException('Announcement delivery status could not be finalized.');
    }
} catch (Throwable $error) {
    error_log('Announcement delivery tracking failed (' . get_class($error) . ', code ' . (int) $error->getCode() . ').');
    announcement_publish_response([
        'ok' => false,
        'announcement_id' => $announcementId,
        'status' => 'publishing',
        'sent_count' => $sentCount,
        'failed_count' => $failedCount,
        'message' => 'The announcement delivery results could not be finalized. Check announcement history before retrying.',
    ], 500);
}

$response = [
    'ok' => $status === 'published',
    'announcement_id' => $announcementId,
    'status' => $status,
    'sent_count' => $sentCount,
    'failed_count' => $failedCount,
    'excluded_count' => $summary['excluded_count'],
];
if ($failedCount > 0) {
    $response['message'] = 'Announcement delivery was incomplete. Review delivery results in announcement history.';
    announcement_publish_response($response, 502);
}
if ($sentCount === 0 && $summary['excluded_count'] > 0) {
    $response['message'] = $summary['excluded_count'] . ' selected student(s) were skipped because they have no valid email address or a duplicate email address.';
}

announcement_publish_response($response);
