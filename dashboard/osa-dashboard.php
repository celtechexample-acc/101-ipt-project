<?php
declare(strict_types=1);

require_once __DIR__ . '/../php-connections/auth.php';

if (!isset($_SESSION['user_id'])) {
    header('Location: ../portals/Ossa-login.php');
    exit;
}

$stmt = $db->prepare('SELECT session_version FROM users WHERE id = :id');
$stmt->execute([':id' => (int) $_SESSION['user_id']]);
$sessionVersion = $stmt->fetchColumn();
if ($sessionVersion === false || (int) $sessionVersion !== (int) ($_SESSION['session_version'] ?? 0)) {
    $_SESSION = [];
    session_destroy();
    header('Location: ../portals/Ossa-login.php');
    exit;
}

$dashboardPath = __DIR__ . '/dashboard-app.html';
$dashboard = file_get_contents($dashboardPath);
if ($dashboard === false) {
    http_response_code(500);
    exit('The dashboard page could not be loaded.');
}

$csrfToken = htmlspecialchars(csrf_token(), ENT_QUOTES, 'UTF-8');
$dashboard = str_replace('__CSRF_TOKEN__', $csrfToken, $dashboard);
$logoutForm = '<form id="logoutForm" action="../php-connections/logout.php" method="post" hidden>'
    . '<input type="hidden" name="csrf_token" value="' . $csrfToken . '"></form>'
    . '<script>document.querySelector(".logout").addEventListener("click", function (event) {'
    . 'event.preventDefault(); if (this.getAttribute("aria-disabled") === "true") return;'
    . 'this.setAttribute("aria-disabled", "true"); this.textContent = "Logging out...";'
    . 'document.body.classList.add("is-submitting"); document.getElementById("logoutForm").submit(); });</script>';

$dashboard = str_replace('</body>', $logoutForm . '</body>', $dashboard);
header('Cache-Control: no-store, private');
echo $dashboard;
