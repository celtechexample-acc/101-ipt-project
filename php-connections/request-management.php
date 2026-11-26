<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');

function request_management_response(array $payload, int $status = 200): never
{
    http_response_code($status);
    echo json_encode($payload, JSON_THROW_ON_ERROR);
    exit;
}

function request_management_is_admin(PDO $db): bool
{
    return isset($_SESSION['user_id']) && is_osa_admin($db);
}

function request_management_rows(PDO $db, string $where, array $params = []): array
{
    $stmt = $db->prepare("SELECT id, requester_name, requester_email, requester_role, audience, audience_details,
            title, message, status, principal_approval_requested_at, principal_decision,
            principal_decision_at, submitted_at, updated_at
        FROM requests WHERE {$where} ORDER BY submitted_at DESC, id DESC LIMIT 500");
    $stmt->execute($params);
    return $stmt->fetchAll();
}

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$action = is_string($_GET['action'] ?? $_POST['action'] ?? null)
    ? ($_GET['action'] ?? $_POST['action'])
    : '';

if ($method === 'GET') {
    if ($action === 'mine') {
        $email = strtolower(trim(is_string($_GET['email'] ?? null) ? $_GET['email'] : ''));
        $role = is_string($_GET['role'] ?? null) ? $_GET['role'] : '';
        if (!filter_var($email, FILTER_VALIDATE_EMAIL) || !in_array($role, ['Teacher', 'Officer'], true)) {
            request_management_response(['ok' => false, 'message' => 'The demo account details are invalid.'], 422);
        }
        request_management_response([
            'ok' => true,
            'requests' => request_management_rows($db, 'requester_email = :email AND requester_role = :role', [
                ':email' => $email,
                ':role' => $role,
            ]),
        ]);
    }

    if ($action === 'admin_list') {
        if (!request_management_is_admin($db)) {
            request_management_response(['ok' => false, 'message' => 'Please log in to the OSA Admin account.'], 401);
        }
        $role = is_string($_GET['role'] ?? null) ? $_GET['role'] : 'All';
        if (!in_array($role, ['All', 'Teacher', 'Officer'], true)) {
            request_management_response(['ok' => false, 'message' => 'Choose a valid requester filter.'], 422);
        }
        $counts = ['pending' => 0, 'for_principal_approval' => 0, 'approved' => 0, 'denied' => 0];
        foreach ($db->query('SELECT status, COUNT(*) AS total FROM requests GROUP BY status') as $count) {
            $counts[$count['status']] = (int) $count['total'];
        }
        $where = $role === 'All' ? '1 = 1' : 'requester_role = :role';
        $params = $role === 'All' ? [] : [':role' => $role];
        request_management_response([
            'ok' => true,
            'counts' => $counts,
            'requests' => request_management_rows($db, $where, $params),
        ]);
    }

    if ($action === 'principal_list') {
        request_management_response([
            'ok' => true,
            'requests' => request_management_rows($db, 'principal_approval_requested_at IS NOT NULL'),
        ]);
    }

    request_management_response(['ok' => false, 'message' => 'Invalid request action.'], 422);
}

if ($method !== 'POST') {
    header('Allow: GET, POST');
    request_management_response(['ok' => false, 'message' => 'Method not allowed.'], 405);
}

if (!csrf_token_is_valid()) {
    request_management_response(['ok' => false, 'message' => 'Your page session expired. Refresh and try again.'], 400);
}

$adminActions = ['forward_principal'];
$principalActions = ['principal_decision'];
if (in_array($action, $adminActions, true) && !request_management_is_admin($db)) {
    request_management_response(['ok' => false, 'message' => 'Please log in to the OSA Admin account.'], 401);
}
if (!in_array($action, ['create', ...$adminActions, ...$principalActions], true)) {
    request_management_response(['ok' => false, 'message' => 'Invalid request action.'], 422);
}

try {
    if ($action === 'create') {
        $name = trim(is_string($_POST['requester_name'] ?? null) ? $_POST['requester_name'] : '');
        $email = strtolower(trim(is_string($_POST['requester_email'] ?? null) ? $_POST['requester_email'] : ''));
        $role = is_string($_POST['requester_role'] ?? null) ? $_POST['requester_role'] : '';
        $audience = is_string($_POST['audience'] ?? null) ? $_POST['audience'] : '';
        $audienceDetails = trim(is_string($_POST['audience_details'] ?? null) ? $_POST['audience_details'] : '');
        $title = trim(is_string($_POST['title'] ?? null) ? $_POST['title'] : '');
        $message = trim(is_string($_POST['message'] ?? null) ? $_POST['message'] : '');
        $idempotencyKey = strtolower(trim(is_string($_POST['idempotency_key'] ?? null) ? $_POST['idempotency_key'] : ''));
        $validAudiences = ['All Students', 'Specific Batch', 'Specific Course', 'Specific Year Level', 'Specific Section', 'Teachers', 'Officers', 'Other'];
        $needsDetails = in_array($audience, ['Specific Batch', 'Specific Course', 'Specific Year Level', 'Specific Section', 'Other'], true);

        if ($name === '' || strlen($name) > 100 || !filter_var($email, FILTER_VALIDATE_EMAIL)
            || !in_array($role, ['Teacher', 'Officer'], true)
            || !in_array($audience, $validAudiences, true)
            || strlen($audienceDetails) > 200 || ($needsDetails && $audienceDetails === '')
            || $title === '' || strlen($title) > 200 || $message === '' || strlen($message) > 20000
            || !preg_match('/^[a-f0-9]{32}$/', $idempotencyKey)) {
            request_management_response(['ok' => false, 'message' => 'Complete all required request fields with valid values.'], 422);
        }

        begin_sqlite_immediate($db);
        $existing = $db->prepare('SELECT id, requester_email, requester_role, status FROM requests WHERE idempotency_key = :key');
        $existing->execute([':key' => $idempotencyKey]);
        $duplicate = $existing->fetch();
        if ($duplicate !== false) {
            if (strcasecmp($duplicate['requester_email'], $email) !== 0 || $duplicate['requester_role'] !== $role) {
                $db->rollBack();
                request_management_response(['ok' => false, 'message' => 'This submission key is already in use. Refresh the page and try again.'], 409);
            }
            $db->commit();
            request_management_response([
                'ok' => true,
                'duplicate' => true,
                'request_id' => (int) $duplicate['id'],
                'status' => $duplicate['status'],
            ]);
        }

        $insert = $db->prepare('INSERT INTO requests
            (idempotency_key, requester_name, requester_email, requester_role, audience, audience_details, title, message)
            VALUES (:key, :name, :email, :role, :audience, :audience_details, :title, :message)');
        $insert->execute([
            ':key' => $idempotencyKey,
            ':name' => $name,
            ':email' => $email,
            ':role' => $role,
            ':audience' => $audience,
            ':audience_details' => $audienceDetails,
            ':title' => $title,
            ':message' => $message,
        ]);
        $requestId = (int) $db->lastInsertId();
        $db->commit();
        request_management_response(['ok' => true, 'request_id' => $requestId, 'status' => 'pending'], 201);
    }

    $requestId = filter_var($_POST['request_id'] ?? null, FILTER_VALIDATE_INT);
    if ($requestId === false || $requestId < 1) {
        request_management_response(['ok' => false, 'message' => 'Choose a valid request.'], 422);
    }

    begin_sqlite_immediate($db);
    if ($action === 'forward_principal') {
        $stmt = $db->prepare("UPDATE requests SET status = 'for_principal_approval',
                principal_approval_requested_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
            WHERE id = :id AND status = 'pending'");
        $stmt->execute([':id' => $requestId]);
        if ($stmt->rowCount() !== 1) {
            $db->rollBack();
            request_management_response(['ok' => false, 'message' => 'Only pending requests can be forwarded. The request may already have changed.'], 409);
        }
        $db->commit();
        request_management_response(['ok' => true, 'status' => 'for_principal_approval']);
    }

    $decision = is_string($_POST['decision'] ?? null) ? $_POST['decision'] : '';
    if (!in_array($decision, ['approved', 'denied'], true)) {
        $db->rollBack();
        request_management_response(['ok' => false, 'message' => 'Choose Approve or Deny.'], 422);
    }
    $stmt = $db->prepare('UPDATE requests SET status = :decision, principal_decision = :decision,
            principal_decision_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
        WHERE id = :id AND status = \'for_principal_approval\'
          AND principal_approval_requested_at IS NOT NULL AND principal_decision IS NULL');
    $stmt->execute([':decision' => $decision, ':id' => $requestId]);
    if ($stmt->rowCount() !== 1) {
        $db->rollBack();
        request_management_response(['ok' => false, 'message' => 'Only forwarded requests awaiting a decision can be decided.'], 409);
    }
    $db->commit();
    request_management_response(['ok' => true, 'status' => $decision, 'decision_date' => date(DATE_ATOM)]);
} catch (Throwable $error) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log('Request workflow failed: ' . $error->getMessage());
    request_management_response(['ok' => false, 'message' => 'The request could not be completed. Please try again.'], 500);
}
