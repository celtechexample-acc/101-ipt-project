<?php
declare(strict_types=1);

require_once __DIR__ . '/../php-connections/auth.php';
$csrfToken = htmlspecialchars(csrf_token(), ENT_QUOTES, 'UTF-8');
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Principal Approval | CELTECH</title>
<link rel="stylesheet" href="../css-folder/osa-dashboard.css">
<link rel="stylesheet" href="../css-folder/request-portals.css">
</head>
<body data-principal-page data-csrf-token="<?= $csrfToken ?>">
<div class="page-loading" aria-hidden="true"><span></span></div>
<div class="scrim"></div>
<aside class="panel" id="sidebar">
  <div class="brand"><img class="portal-sidebar-logo" src="../logo/image/icons/converted.png" alt="CELTECH logo"><div><b>CELTECH OSSA</b><small>Principal Approval</small></div></div>
  <nav aria-label="Principal menu"><a href="#approval" data-go="approval" aria-current="page">OSSA Request</a></nav>
</aside>
<main class="portal-main">
  <header class="top panel">
    <div class="bar">
      <button class="icon-btn burger" type="button" aria-label="Open menu" aria-expanded="false" aria-controls="sidebar">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M4 7h16M4 12h16M4 17h16"/></svg>
      </button>
      <div class="tools"><div class="user"><span class="avatar">P</span><div><b>Principal</b><small>Approval Review</small></div></div></div>
    </div>
    <div class="hero"><div><small>CELTECH COLLEGE · OSSA</small><h1>Principal Approval</h1><p>Review requests forwarded by the Office of Student Affairs.</p></div></div>
  </header>
  <section class="view portal-content" id="v-approval" data-title="OSSA Request" data-sub="Requests explicitly forwarded for Principal approval.">
    <p class="hint">Standalone demonstration page. No separate Principal sign-in is configured.</p>
    <section class="panel" aria-labelledby="approvalHeading">
      <div class="sec-head"><div><h2 id="approvalHeading">OSSA Requests</h2><p class="hint">Only requests forwarded for approval appear here.</p></div><button class="btn ghost sm" id="refreshApprovals" type="button">Refresh</button></div>
      <div class="request-list" id="principalRequests" aria-live="polite"><div class="empty box"><b>Loading forwarded requests</b>Checking the shared request records.</div></div>
    </section>
  </section>
</main>
<dialog class="request-detail-dialog" id="principalDetails" aria-labelledby="principalDetailTitle"><article class="request-detail">
  <div class="request-detail-head"><div><h2 id="principalDetailTitle"></h2><span class="status-badge" id="principalDetailStatus"></span></div><button class="request-detail-close" type="button" data-close-principal aria-label="Close details">×</button></div>
  <dl class="request-detail-grid" id="principalDetailFields"></dl><div class="request-message" id="principalDetailMessage"></div>
  <div class="request-detail-actions" id="principalDetailActions"><button class="btn ghost" type="button" data-close-principal>Close</button></div>
</article></dialog>
<script src="principal-approval.js" defer></script>
</body>
</html>
