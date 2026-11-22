<?php
declare(strict_types=1);

function login_security_ip_hash(): string
{
    $ipAddress = $_SERVER['REMOTE_ADDR'] ?? '';
    if (!is_string($ipAddress) || filter_var($ipAddress, FILTER_VALIDATE_IP) === false) {
        throw new RuntimeException('A valid client IP address is required for login throttling.');
    }

    return hash('sha256', $ipAddress);
}

function user_login_lockout_remaining(PDO $db, int $userId, int $now): int
{
    $stmt = $db->prepare('SELECT locked_until FROM user_login_security WHERE user_id = :user_id');
    $stmt->execute([':user_id' => $userId]);
    $lockedUntil = $stmt->fetchColumn();

    return $lockedUntil !== false && $lockedUntil !== null && (int) $lockedUntil > $now
        ? (int) $lockedUntil - $now
        : 0;
}

function ip_login_lockout_remaining(PDO $db, string $ipHash, int $now): int
{
    $stmt = $db->prepare('SELECT locked_until FROM login_ip_security WHERE ip_hash = :ip_hash');
    $stmt->execute([':ip_hash' => $ipHash]);
    $lockedUntil = $stmt->fetchColumn();

    return $lockedUntil !== false && $lockedUntil !== null && (int) $lockedUntil > $now
        ? (int) $lockedUntil - $now
        : 0;
}

function record_failed_login(PDO $db, ?int $userId, string $ipHash, int $now): int
{
    $lockoutDurations = [60, 300, 900, 1800, 3600];
    $ipWindowSeconds = 900;
    $ipMaxFailures = 20;

    begin_sqlite_immediate($db);
    try {
        $stmt = $db->prepare('DELETE FROM login_ip_security WHERE updated_at < :cutoff');
        $stmt->execute([':cutoff' => $now - 86400]);
        $stmt = $db->prepare('SELECT failed_attempts, window_started_at, locked_until FROM login_ip_security WHERE ip_hash = :ip_hash');
        $stmt->execute([':ip_hash' => $ipHash]);
        $ipSecurity = $stmt->fetch();
        if ($ipSecurity !== false && $ipSecurity['locked_until'] !== null && (int) $ipSecurity['locked_until'] > $now) {
            $db->rollBack();
            return (int) $ipSecurity['locked_until'] - $now;
        }

        $accountRemaining = 0;
        if ($userId !== null) {
            $stmt = $db->prepare('SELECT failed_attempts, lockout_level, locked_until FROM user_login_security WHERE user_id = :user_id');
            $stmt->execute([':user_id' => $userId]);
            $security = $stmt->fetch();
            if ($security !== false && $security['locked_until'] !== null && (int) $security['locked_until'] > $now) {
                $db->rollBack();
                return (int) $security['locked_until'] - $now;
            }

            $failures = $security === false ? 0 : (int) $security['failed_attempts'];
            $level = $security === false ? 0 : (int) $security['lockout_level'];
            $failures++;
            $lockedUntil = null;
            if ($failures >= 5) {
                $level = min($level + 1, count($lockoutDurations));
                $lockedUntil = $now + $lockoutDurations[$level - 1];
                $failures = 0;
                $accountRemaining = $lockedUntil - $now;
            }

            $stmt = $db->prepare("
                INSERT INTO user_login_security (user_id, failed_attempts, lockout_level, locked_until, updated_at)
                VALUES (:user_id, :failed_attempts, :lockout_level, :locked_until, :updated_at)
                ON CONFLICT(user_id) DO UPDATE SET
                    failed_attempts = excluded.failed_attempts,
                    lockout_level = excluded.lockout_level,
                    locked_until = excluded.locked_until,
                    updated_at = excluded.updated_at
            ");
            $stmt->execute([
                ':user_id' => $userId,
                ':failed_attempts' => $failures,
                ':lockout_level' => $level,
                ':locked_until' => $lockedUntil,
                ':updated_at' => $now,
            ]);
        }

        $windowStartedAt = $ipSecurity === false ? $now : (int) $ipSecurity['window_started_at'];
        $ipFailures = $ipSecurity === false || $now - $windowStartedAt >= $ipWindowSeconds
            ? 0
            : (int) $ipSecurity['failed_attempts'];
        if ($ipSecurity === false || $now - $windowStartedAt >= $ipWindowSeconds) {
            $windowStartedAt = $now;
        }
        $ipFailures++;
        $ipLockedUntil = null;
        if ($ipFailures >= $ipMaxFailures) {
            $ipFailures = 0;
            $windowStartedAt = $now;
            $ipLockedUntil = $now + $ipWindowSeconds;
        }

        $stmt = $db->prepare("
            INSERT INTO login_ip_security (ip_hash, failed_attempts, window_started_at, locked_until, updated_at)
            VALUES (:ip_hash, :failed_attempts, :window_started_at, :locked_until, :updated_at)
            ON CONFLICT(ip_hash) DO UPDATE SET
                failed_attempts = excluded.failed_attempts,
                window_started_at = excluded.window_started_at,
                locked_until = excluded.locked_until,
                updated_at = excluded.updated_at
        ");
        $stmt->execute([
            ':ip_hash' => $ipHash,
            ':failed_attempts' => $ipFailures,
            ':window_started_at' => $windowStartedAt,
            ':locked_until' => $ipLockedUntil,
            ':updated_at' => $now,
        ]);

        $db->commit();
        return max($accountRemaining, $ipLockedUntil === null ? 0 : $ipLockedUntil - $now);
    } catch (Throwable $e) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        throw $e;
    }
}

function record_successful_login(PDO $db, int $userId, string $ipHash, int $now): int
{
    begin_sqlite_immediate($db);
    try {
        $stmt = $db->prepare('SELECT locked_until FROM user_login_security WHERE user_id = :user_id');
        $stmt->execute([':user_id' => $userId]);
        $userLockedUntil = $stmt->fetchColumn();
        $stmt = $db->prepare('SELECT locked_until FROM login_ip_security WHERE ip_hash = :ip_hash');
        $stmt->execute([':ip_hash' => $ipHash]);
        $ipLockedUntil = $stmt->fetchColumn();
        $remaining = max(
            $userLockedUntil !== false && $userLockedUntil !== null && (int) $userLockedUntil > $now
                ? (int) $userLockedUntil - $now
                : 0,
            $ipLockedUntil !== false && $ipLockedUntil !== null && (int) $ipLockedUntil > $now
                ? (int) $ipLockedUntil - $now
                : 0
        );
        if ($remaining > 0) {
            $db->rollBack();
            return $remaining;
        }

        $stmt = $db->prepare('UPDATE user_login_security SET failed_attempts = 0, lockout_level = 0, locked_until = NULL, updated_at = :now WHERE user_id = :user_id');
        $stmt->execute([':now' => $now, ':user_id' => $userId]);
        $stmt = $db->prepare('DELETE FROM login_ip_security WHERE ip_hash = :ip_hash');
        $stmt->execute([':ip_hash' => $ipHash]);
        $db->commit();
        return 0;
    } catch (Throwable $e) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        throw $e;
    }
}
