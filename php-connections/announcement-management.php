<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');

function announcement_management_response(array $payload, int $status = 200): never
{
    http_response_code($status);
    echo json_encode($payload, JSON_THROW_ON_ERROR);
    exit;
}

if (!isset($_SESSION['user_id']) || !is_osa_admin($db)) {
    announcement_management_response(['ok' => false, 'message' => 'Please log in to the OSA Admin account.'], 401);
}

$adminId = (int) $_SESSION['user_id'];
$method = $_SERVER['REQUEST_METHOD'] ?? '';
$action = is_string($_GET['action'] ?? $_POST['action'] ?? null)
    ? ($_GET['action'] ?? $_POST['action'])
    : '';

if ($method === 'GET') {
    if ($action === 'list') {
        try {
            $stmt = $db->prepare('
                SELECT a.id, a.title, a.audience_json, a.publish_date, a.status, a.created_at, a.updated_at,
                       a.published_at, a.sent_count, a.failed_count, a.excluded_count,
                       (SELECT COUNT(*) FROM announcement_recipients r WHERE r.announcement_id = a.id) AS recipient_count
                FROM announcements a
                WHERE a.created_by = :created_by
                ORDER BY a.updated_at DESC, a.created_at DESC
                LIMIT 500
            ');
            $stmt->execute([':created_by' => $adminId]);
            announcement_management_response(['ok' => true, 'announcements' => $stmt->fetchAll()]);
        } catch (Throwable $error) {
            error_log('Announcement history load failed: ' . $error->getMessage());
            announcement_management_response(['ok' => false, 'message' => 'Announcement history could not be loaded. Please try again.'], 500);
        }
    }

    if ($action === 'details') {
        $id = is_string($_GET['id'] ?? null) ? $_GET['id'] : '';
        if (!preg_match('/^[a-f0-9]{32}$/', $id)) {
            announcement_management_response(['ok' => false, 'message' => 'Choose a valid announcement.'], 422);
        }

        try {
            $stmt = $db->prepare('
                SELECT id, title, details, audience_json, publish_date, status, created_at, updated_at,
                       published_at, sent_count, failed_count, excluded_count
                FROM announcements
                WHERE id = :id AND created_by = :created_by
                LIMIT 1
            ');
            $stmt->execute([':id' => $id, ':created_by' => $adminId]);
            $announcement = $stmt->fetch();
            if ($announcement === false) {
                announcement_management_response(['ok' => false, 'message' => 'Announcement not found.'], 404);
            }

            $recipients = $db->prepare('
                SELECT r.student_id, s.student_name, r.delivery_status, r.delivered_at
                FROM announcement_recipients r
                JOIN students s ON s.id = r.student_id
                WHERE r.announcement_id = :announcement_id
                ORDER BY s.student_name COLLATE NOCASE, s.id
            ');
            $recipients->execute([':announcement_id' => $id]);
            announcement_management_response([
                'ok' => true,
                'announcement' => $announcement,
                'recipients' => $recipients->fetchAll(),
            ]);
        } catch (Throwable $error) {
            error_log('Announcement details load failed: ' . $error->getMessage());
            announcement_management_response(['ok' => false, 'message' => 'Announcement details could not be loaded. Please try again.'], 500);
        }
    }

    announcement_management_response(['ok' => false, 'message' => 'Invalid announcement action.'], 422);
}

if ($method !== 'POST') {
    header('Allow: GET, POST');
    announcement_management_response(['ok' => false, 'message' => 'Method not allowed.'], 405);
}
if (!csrf_token_is_valid()) {
    announcement_management_response(['ok' => false, 'message' => 'Your session expired. Refresh the dashboard and try again.'], 400);
}

if ($action === 'save_draft') {
    $title = trim(is_string($_POST['title'] ?? null) ? $_POST['title'] : '');
    $details = trim(is_string($_POST['details'] ?? null) ? $_POST['details'] : '');
    $id = trim(is_string($_POST['announcement_id'] ?? null) ? $_POST['announcement_id'] : '');
    $publishDate = trim(is_string($_POST['date'] ?? null) ? $_POST['date'] : '');
    $audienceJson = trim(is_string($_POST['audience'] ?? null) ? $_POST['audience'] : '');

    if ($title === '' || strlen($title) > 200 || preg_match('/[\r\n\x00]/', $title)
        || $details === '' || strlen($details) > 50000) {
        announcement_management_response(['ok' => false, 'message' => 'Enter a title (up to 200 characters) and details (up to 50,000 characters).'], 422);
    }
    if ($publishDate !== '') {
        $parsedDate = DateTimeImmutable::createFromFormat('!Y-m-d', $publishDate);
        if ($parsedDate === false || $parsedDate->format('Y-m-d') !== $publishDate) {
            announcement_management_response(['ok' => false, 'message' => 'Enter a valid announcement date.'], 422);
        }
    } else {
        $publishDate = null;
    }

    $audience = null;
    if ($audienceJson !== '') {
        if (strlen($audienceJson) > 1048576) {
            announcement_management_response(['ok' => false, 'message' => 'The saved recipient selection is too large.'], 422);
        }
        try {
            $audience = json_decode($audienceJson, true, 16, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            announcement_management_response(['ok' => false, 'message' => 'The recipient selection is invalid. Review it and try again.'], 422);
        }
        if (!is_array($audience) || !in_array($audience['mode'] ?? null, ['all_active', 'selective'], true)) {
            announcement_management_response(['ok' => false, 'message' => 'The recipient selection is invalid. Review it and try again.'], 422);
        }
        if ($audience['mode'] === 'selective') {
            $studentIds = $audience['student_ids'] ?? null;
            $seenIds = [];
            $hasHierarchy = array_key_exists('batch', $audience)
                || array_key_exists('course_id', $audience)
                || array_key_exists('section_id', $audience)
                || array_key_exists('year_level', $audience);
            if (!is_array($studentIds) || $studentIds === [] || count($studentIds) > 10000) {
                announcement_management_response(['ok' => false, 'message' => 'The saved student selection is incomplete. Confirm the recipient selection first.'], 422);
            }
            if ($hasHierarchy) {
                $batch = filter_var($audience['batch'] ?? null, FILTER_VALIDATE_INT);
                $courseId = filter_var($audience['course_id'] ?? null, FILTER_VALIDATE_INT);
                $sectionId = filter_var($audience['section_id'] ?? null, FILTER_VALIDATE_INT);
                $yearLevel = $audience['year_level'] ?? null;
                if ($batch === false || $batch < 1 || $courseId === false || $courseId < 1
                    || $sectionId === false || $sectionId < 1
                    || !is_string($yearLevel) || $yearLevel === '' || strlen($yearLevel) > 100) {
                    announcement_management_response(['ok' => false, 'message' => 'The saved student selection is incomplete. Confirm the recipient selection first.'], 422);
                }
            }
            foreach ($studentIds as $studentId) {
                if (!is_int($studentId) && !is_string($studentId)) {
                    announcement_management_response(['ok' => false, 'message' => 'The saved student selection is invalid. Review it and try again.'], 422);
                }
                $validatedId = filter_var($studentId, FILTER_VALIDATE_INT);
                if ($validatedId === false || $validatedId < 1 || isset($seenIds[$validatedId])) {
                    announcement_management_response(['ok' => false, 'message' => 'The saved student selection is invalid. Review it and try again.'], 422);
                }
                $seenIds[$validatedId] = true;
            }
        }
        $audienceJson = json_encode($audience, JSON_THROW_ON_ERROR);
    } else {
        $audienceJson = null;
    }

    if ($id !== '' && !preg_match('/^[a-f0-9]{32}$/', $id)) {
        announcement_management_response(['ok' => false, 'message' => 'The draft identifier is invalid.'], 422);
    }

    try {
        begin_sqlite_immediate($db);
        if ($id === '') {
            $id = bin2hex(random_bytes(16));
            $stmt = $db->prepare('
                INSERT INTO announcements
                    (id, title, details, audience_json, publish_date, status, created_by)
                VALUES
                    (:id, :title, :details, :audience_json, :publish_date, \'draft\', :created_by)
            ');
            $stmt->execute([
                ':id' => $id,
                ':title' => $title,
                ':details' => $details,
                ':audience_json' => $audienceJson,
                ':publish_date' => $publishDate,
                ':created_by' => $adminId,
            ]);
        } else {
            $stmt = $db->prepare('
                UPDATE announcements
                SET title = :title,
                    details = :details,
                    audience_json = :audience_json,
                    publish_date = :publish_date,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = :id AND created_by = :created_by AND status = \'draft\'
            ');
            $stmt->execute([
                ':title' => $title,
                ':details' => $details,
                ':audience_json' => $audienceJson,
                ':publish_date' => $publishDate,
                ':id' => $id,
                ':created_by' => $adminId,
            ]);
            if ($stmt->rowCount() !== 1) {
                $db->rollBack();
                announcement_management_response(['ok' => false, 'message' => 'This draft no longer exists or cannot be edited. Refresh the draft list.'], 409);
            }
        }
        $db->commit();
        announcement_management_response(['ok' => true, 'message' => 'Draft saved.', 'announcement_id' => $id]);
    } catch (Throwable $error) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        error_log('Announcement draft save failed: ' . $error->getMessage());
        announcement_management_response(['ok' => false, 'message' => 'The draft could not be saved. Please try again.'], 500);
    }
}

if ($action === 'delete_draft') {
    $id = is_string($_POST['announcement_id'] ?? null) ? $_POST['announcement_id'] : '';
    if (!preg_match('/^[a-f0-9]{32}$/', $id)) {
        announcement_management_response(['ok' => false, 'message' => 'Choose a valid draft.'], 422);
    }

    try {
        $stmt = $db->prepare('
            DELETE FROM announcements
            WHERE id = :id AND created_by = :created_by AND status = \'draft\'
        ');
        $stmt->execute([':id' => $id, ':created_by' => $adminId]);
        if ($stmt->rowCount() !== 1) {
            announcement_management_response(['ok' => false, 'message' => 'This draft no longer exists or cannot be deleted. Refresh the draft list.'], 409);
        }
    } catch (Throwable $error) {
        error_log('Announcement draft deletion failed: ' . $error->getMessage());
        announcement_management_response(['ok' => false, 'message' => 'The draft could not be deleted. Please try again.'], 500);
    }
    announcement_management_response(['ok' => true, 'message' => 'Draft deleted.']);
}

announcement_management_response(['ok' => false, 'message' => 'Invalid announcement action.'], 422);
