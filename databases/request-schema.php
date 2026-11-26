<?php
declare(strict_types=1);

function ensure_request_schema(PDO $db): void
{
    $db->exec("
        CREATE TABLE IF NOT EXISTS requests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idempotency_key TEXT NOT NULL UNIQUE CHECK (length(idempotency_key) = 32),
            requester_name TEXT NOT NULL CHECK (length(trim(requester_name)) BETWEEN 1 AND 100),
            requester_email TEXT NOT NULL COLLATE NOCASE,
            requester_role TEXT NOT NULL CHECK (requester_role IN ('Teacher', 'Officer')),
            audience TEXT NOT NULL CHECK (audience IN (
                'All Students', 'Specific Batch', 'Specific Course', 'Specific Year Level',
                'Specific Section', 'Teachers', 'Officers', 'Other'
            )),
            audience_details TEXT NOT NULL DEFAULT '',
            title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 200),
            message TEXT NOT NULL CHECK (length(trim(message)) BETWEEN 1 AND 20000),
            status TEXT NOT NULL DEFAULT 'pending' CHECK (
                status IN ('pending', 'for_principal_approval', 'approved', 'denied')
            ),
            principal_approval_requested_at TEXT,
            principal_decision TEXT CHECK (principal_decision IS NULL OR principal_decision IN ('approved', 'denied')),
            principal_decision_at TEXT,
            submitted_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            CHECK (
                (status IN ('pending', 'for_principal_approval') AND principal_decision IS NULL AND principal_decision_at IS NULL)
                OR (status IN ('approved', 'denied') AND principal_decision = status AND principal_decision_at IS NOT NULL)
            ),
            CHECK (
                (status = 'pending' AND principal_approval_requested_at IS NULL)
                OR (status <> 'pending' AND principal_approval_requested_at IS NOT NULL)
            )
        )
    ");
    $db->exec('CREATE INDEX IF NOT EXISTS requests_status_submitted ON requests(status, submitted_at DESC, id DESC)');
    $db->exec('CREATE INDEX IF NOT EXISTS requests_requester_submitted ON requests(requester_email, submitted_at DESC, id DESC)');
}
