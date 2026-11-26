<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');

function announcement_review_version_hash(string $title, string $details, string $publishDate, array $audience): string
{
    ksort($audience);
    if (isset($audience['student_ids']) && is_array($audience['student_ids'])) {
        $ids = array_map('intval', $audience['student_ids']);
        sort($ids);
        $audience['student_ids'] = $ids;
    }
    return hash('sha256', json_encode([
        'title' => $title,
        'details' => $details,
        'publish_date' => $publishDate,
        'audience' => $audience,
    ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
}

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

    if ($action === 'review_status') {
        $id = is_string($_GET['id'] ?? null) ? $_GET['id'] : '';
        if (!preg_match('/^[a-f0-9]{32}$/', $id)) {
            announcement_management_response(['ok' => false, 'message' => 'Choose a valid announcement.'], 422);
        }
        if (!isset($_SESSION['user_id']) || !is_osa_admin($db)) {
            announcement_management_response(['ok' => false, 'message' => 'Please log in to the OSA Admin account.'], 401);
        }
        $stmt = $db->prepare("
            SELECT r.id, r.announcement_id, r.version_hash, r.status, r.review_note,
                   r.submitted_at, r.reviewed_at, r.reviewed_by,
                   u.name AS reviewer_name
            FROM announcement_approval_requests r
            LEFT JOIN users u ON u.id = r.reviewed_by
            JOIN announcements a ON a.id = r.announcement_id
            WHERE r.announcement_id = :id AND a.created_by = :created_by
            ORDER BY r.submitted_at DESC, r.id DESC
        ");
        $stmt->execute([':id' => $id, ':created_by' => (int) $_SESSION['user_id']]);
        announcement_management_response(['ok' => true, 'reviews' => $stmt->fetchAll()]);
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

    if ($action === 'principal_list') {
        if (!isset($_SESSION['user_id']) || is_osa_admin($db)) {
            announcement_management_response(['ok' => false, 'message' => 'Please log in with an authorized Principal account.'], 401);
        }
        $stmt = $db->prepare("
            SELECT r.id AS review_id, r.status AS review_status, r.review_note, r.submitted_at,
                   r.reviewed_at, r.version_hash,
                   a.id, a.title, a.details, a.audience_json, a.publish_date, a.created_by,
                   a.created_at, a.updated_at, u.name AS submitted_by_name
            FROM announcement_approval_requests r
            JOIN announcements a ON a.id = r.announcement_id
            JOIN users u ON u.id = r.submitted_by
            ORDER BY r.submitted_at DESC, r.id DESC
            LIMIT 500
        ");
        $stmt->execute();
        announcement_management_response(['ok' => true, 'reviews' => $stmt->fetchAll()]);
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

if ($action === 'request_principal_review') {
    if (!isset($_SESSION['user_id']) || !is_osa_admin($db)) {
        announcement_management_response(['ok' => false, 'message' => 'Please log in to the OSA Admin account.'], 401);
    }

    $title = trim(is_string($_POST['title'] ?? null) ? $_POST['title'] : '');
    $details = trim(is_string($_POST['details'] ?? null) ? $_POST['details'] : '');
    $date = is_string($_POST['date'] ?? null) ? $_POST['date'] : '';
    $audienceJson = is_string($_POST['audience'] ?? null) ? $_POST['audience'] : '';
    $id = trim(is_string($_POST['announcement_id'] ?? null) ? $_POST['announcement_id'] : '');

    if ($title === '' || strlen($title) > 200 || preg_match('/[\r\n\x00]/', $title)
        || $details === '' || strlen($details) > 50000
        || $date === '' || $audienceJson === '') {
        announcement_management_response(['ok' => false, 'message' => 'Complete the title, details, publish date, and confirmed recipient selection.'], 422);
    }
    $parsedDate = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
    if ($parsedDate === false || $parsedDate->format('Y-m-d') !== $date) {
        announcement_management_response(['ok' => false, 'message' => 'Enter a valid publish date.'], 422);
    }
    try {
        $audience = json_decode($audienceJson, true, 16, JSON_THROW_ON_ERROR);
    } catch (JsonException) {
        announcement_management_response(['ok' => false, 'message' => 'Confirm the recipient selection before requesting review.'], 422);
    }
    if (!is_array($audience) || !in_array($audience['mode'] ?? null, ['all_active', 'selective'], true)) {
        announcement_management_response(['ok' => false, 'message' => 'Confirm the recipient selection before requesting review.'], 422);
    }
    if (($audience['mode'] === 'selective')
        && (!is_array($audience['student_ids'] ?? null) || $audience['student_ids'] === [])) {
        announcement_management_response(['ok' => false, 'message' => 'Select eligible students before requesting review.'], 422);
    }
    if ($id !== '' && !preg_match('/^[a-f0-9]{32}$/', $id)) {
        announcement_management_response(['ok' => false, 'message' => 'The announcement identifier is invalid.'], 422);
    }

    try {
        begin_sqlite_immediate($db);
        if ($id === '') {
            $id = bin2hex(random_bytes(16));
            $stmt = $db->prepare("
                INSERT INTO announcements
                    (id, title, details, audience_json, publish_date, status, created_by)
                VALUES (:id, :title, :details, :audience_json, :date, 'draft', :created_by)
            ");
            $stmt->execute([
                ':id' => $id, ':title' => $title, ':details' => $details,
                ':audience_json' => json_encode($audience, JSON_THROW_ON_ERROR),
                ':date' => $date, ':created_by' => $adminId,
            ]);
        } else {
            $stmt = $db->prepare("
                UPDATE announcements
                SET title = :title, details = :details, audience_json = :audience_json,
                    publish_date = :date, status = 'draft', updated_at = CURRENT_TIMESTAMP
                WHERE id = :id AND created_by = :created_by
            ");
            $stmt->execute([
                ':title' => $title, ':details' => $details,
                ':audience_json' => json_encode($audience, JSON_THROW_ON_ERROR),
                ':date' => $date, ':id' => $id, ':created_by' => $adminId,
            ]);
            if ($stmt->rowCount() !== 1) {
                $db->rollBack();
                announcement_management_response(['ok' => false, 'message' => 'This announcement could not be submitted for review.'], 409);
            }
        }

        $normalizedAudienceJson = json_encode($audience, JSON_THROW_ON_ERROR);
        $versionHash = announcement_review_version_hash($title, $details, $date, $audience);
        $existing = $db->prepare("
            SELECT id FROM announcement_approval_requests
            WHERE announcement_id = :id AND version_hash = :hash
            LIMIT 1
        ");
        $existing->execute([':id' => $id, ':hash' => $versionHash]);
        if ($existing->fetch() === false) {
            $insert = $db->prepare("
                INSERT INTO announcement_approval_requests
                    (announcement_id, submitted_by, version_hash, status)
                VALUES (:id, :submitted_by, :hash, 'pending')
            ");
            $insert->execute([
                ':id' => $id, ':submitted_by' => $adminId, ':hash' => $versionHash,
            ]);
        } else {
            $reset = $db->prepare("
                UPDATE announcement_approval_requests
                SET status = 'pending', review_note = '', reviewed_by = NULL, reviewed_at = NULL,
                    submitted_at = CURRENT_TIMESTAMP
                WHERE announcement_id = :id AND version_hash = :hash
            ");
            $reset->execute([':id' => $id, ':hash' => $versionHash]);
        }
        $db->commit();
        announcement_management_response([
            'ok' => true,
            'message' => 'Announcement submitted for Principal review.',
            'announcement_id' => $id,
            'status' => 'pending',
            'review_status' => 'pending',
        ]);
    } catch (Throwable $error) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        error_log('Announcement Principal review submission failed: ' . $error->getMessage());
        announcement_management_response(['ok' => false, 'message' => 'The announcement could not be submitted for review.'], 500);
    }
}

if ($action === 'principal_decision') {
    if (!isset($_SESSION['user_id']) || is_osa_admin($db)) {
        announcement_management_response(['ok' => false, 'message' => 'Please log in with an authorized Principal account.'], 401);
    }
    $reviewId = filter_var($_POST['review_id'] ?? null, FILTER_VALIDATE_INT);
    $decision = is_string($_POST['decision'] ?? null) ? $_POST['decision'] : '';
    $note = trim(is_string($_POST['review_note'] ?? null) ? $_POST['review_note'] : '');
    if ($reviewId === false || $reviewId < 1
        || !in_array($decision, ['approved', 'changes_requested'], true)
        || ($decision === 'changes_requested' && $note === '')) {
        announcement_management_response(['ok' => false, 'message' => 'Choose a valid decision and provide review notes when requesting changes.'], 422);
    }
    if (strlen($note) > 5000) {
        announcement_management_response(['ok' => false, 'message' => 'Principal review notes must be 5,000 characters or fewer.'], 422);
    }
    try {
        begin_sqlite_immediate($db);
        $principalId = (int) $_SESSION['user_id'];
        $stmt = $db->prepare("
            UPDATE announcement_approval_requests
            SET status = :status, review_note = :note, reviewed_by = :principal_id,
                reviewed_at = CURRENT_TIMESTAMP
            WHERE id = :id AND status = 'pending'
              AND submitted_by != :principal_id
        ");
        $stmt->execute([
            ':status' => $decision, ':note' => $note, ':principal_id' => $principalId,
            ':id' => $reviewId,
        ]);
        if ($stmt->rowCount() !== 1) {
            $db->rollBack();
            announcement_management_response(['ok' => false, 'message' => 'This review is no longer pending or cannot be decided by this account.'], 409);
        }
        $db->commit();
        announcement_management_response([
            'ok' => true,
            'status' => $decision,
            'review_note' => $note,
        ]);
    } catch (Throwable $error) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        error_log('Announcement Principal decision failed: ' . $error->getMessage());
        announcement_management_response(['ok' => false, 'message' => 'The review decision could not be saved.'], 500);
    }
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
