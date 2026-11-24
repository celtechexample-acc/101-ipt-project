<?php
declare(strict_types=1);

function ensure_announcement_schema(PDO $db): void
{
    if ($db->inTransaction()) {
        throw new LogicException('Announcement schema migration cannot run inside another transaction.');
    }

    $db->beginTransaction();
    try {
        $db->exec("
            CREATE TABLE IF NOT EXISTS announcements (
                id TEXT PRIMARY KEY NOT NULL,
                title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 200),
                details TEXT NOT NULL CHECK (length(trim(details)) BETWEEN 1 AND 50000),
                audience_json TEXT,
                publish_date TEXT,
                status TEXT NOT NULL CHECK (
                    status IN ('draft', 'publishing', 'published', 'partial_delivery', 'delivery_failed')
                ),
                created_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                published_at TEXT,
                publish_request_id TEXT UNIQUE,
                sent_count INTEGER NOT NULL DEFAULT 0 CHECK (sent_count >= 0),
                failed_count INTEGER NOT NULL DEFAULT 0 CHECK (failed_count >= 0),
                excluded_count INTEGER NOT NULL DEFAULT 0 CHECK (excluded_count >= 0)
            )
        ");
        $db->exec('CREATE INDEX IF NOT EXISTS announcements_owner_status ON announcements(created_by, status, updated_at DESC)');
        $db->exec('CREATE INDEX IF NOT EXISTS announcements_created_at ON announcements(created_at DESC)');

        $db->exec("
            CREATE TABLE IF NOT EXISTS announcement_recipients (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                announcement_id TEXT NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
                student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
                recipient_email TEXT NOT NULL COLLATE NOCASE,
                delivery_status TEXT NOT NULL DEFAULT 'pending'
                    CHECK (delivery_status IN ('pending', 'sent', 'failed')),
                delivered_at TEXT,
                failure_code TEXT,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UNIQUE (announcement_id, student_id),
                UNIQUE (announcement_id, recipient_email)
            )
        ");
        $db->exec('CREATE INDEX IF NOT EXISTS announcement_recipients_delivery ON announcement_recipients(announcement_id, delivery_status)');
        $db->commit();
    } catch (Throwable $error) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        throw $error;
    }
}
