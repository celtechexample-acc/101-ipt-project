<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/login-security.php';

function password_reset_json_response(array $payload, int $status = 200): never
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store, private');
    echo json_encode($payload, JSON_THROW_ON_ERROR);
    exit;
}

function password_reset_require_post(): void
{
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        header('Allow: POST');
        password_reset_json_response(['ok' => false, 'message' => 'Method not allowed.'], 405);
    }
}

function password_reset_require_csrf(): void
{
    if (!csrf_token_is_valid()) {
        password_reset_json_response([
            'ok' => false,
            'message' => 'Your form session expired. Refresh the page and try again.',
        ], 400);
    }
}

function password_reset_ip_hash(): string
{
    return login_security_ip_hash();
}
