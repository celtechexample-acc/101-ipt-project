<?php
declare(strict_types=1);

require_once __DIR__ . '/../php-connections/auth.php';
$portalRole = $portalRole === 'Officer' ? 'Officer' : 'Teacher';
$csrfToken = htmlspecialchars(csrf_token(), ENT_QUOTES, 'UTF-8');
$portalRoleHtml = htmlspecialchars($portalRole, ENT_QUOTES, 'UTF-8');
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= $portalRoleHtml ?> Portal | CELTECH</title>
<link rel="stylesheet" href="../css-folder/osa-dashboard.css">
<link rel="stylesheet" href="../css-folder/request-portals.css">
</head>
<body data-request-portal data-portal-role="<?= $portalRoleHtml ?>" data-csrf-token="<?= $csrfToken ?>">
<div class="page-loading" aria-hidden="true"><span></span></div>
<div class="scrim"></div>
<aside class="panel" id="sidebar">
  <div class="brand"><img class="portal-sidebar-logo" src="../logo/image/icons/converted.png" alt="CELTECH logo"><div><b>CELTECH OSSA</b><small><?= $portalRoleHtml ?> Portal</small></div></div>
  <nav aria-label="Portal menu"><a href="#request" data-go="request" aria-current="page">Request</a></nav>
</aside>
<main class="portal-main">
  <header class="top panel">
    <div class="bar">
      <button class="icon-btn burger" type="button" aria-label="Open menu" aria-expanded="false" aria-controls="sidebar">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M4 7h16M4 12h16M4 17h16"/></svg>
      </button>
      <div class="tools"><div class="user"><span class="avatar" id="requesterAvatar">--</span><div><b id="requesterHeader">Loading account</b><small><?= $portalRoleHtml ?></small></div></div><button class="btn light" type="button" data-demo-logout>Log out</button></div>
    </div>
    <div class="hero"><div><small>CELTECH COLLEGE · OFFICE OF STUDENT AFFAIRS</small><h1><?= $portalRoleHtml ?> Request Portal</h1><p>Submit a request and follow its status.</p></div></div>
  </header>
  <section class="view portal-content" id="v-request" data-title="Request" data-sub="Submit a request to the Office of Student Affairs.">
    <form class="panel request-form" id="requestForm">
      <input type="hidden" name="csrf_token" value="<?= $csrfToken ?>">
      <div class="sec-head"><div><h2>Submit a request</h2><p class="hint">Your account name is attached automatically.</p></div></div>
      <div class="fld requester-field"><label for="requesterName">Requester Name</label><input id="requesterName" name="requester_name" type="text" readonly required></div>
      <div class="fld"><label for="requestAudience">Audience</label>
        <select id="requestAudience" name="audience" required>
          <option value="">Select an audience</option>
          <option>All Students</option><option>Specific Batch</option><option>Specific Course</option>
          <option>Specific Year Level</option><option>Specific Section</option><option>Teachers</option>
          <option>Officers</option><option>Other</option>
        </select>
        <div class="fld audience-detail" id="audienceDetailField" hidden><label id="audienceDetailLabel" for="audienceDetails">Audience details</label><input id="audienceDetails" name="audience_details" type="text" maxlength="200"></div>
      </div>
      <div class="fld"><label for="requestTitle">Request Title</label><input id="requestTitle" name="title" type="text" maxlength="200" required></div>
      <div class="fld"><label for="requestMessage">Request Message</label><textarea id="requestMessage" name="message" maxlength="20000" required></textarea></div>
      <p class="form-message request-status" id="requestStatus" role="status" aria-live="polite" hidden></p>
      <div class="form-actions"><button class="btn green" type="submit" id="submitRequest">Submit Request</button></div>
    </form>
    <section class="panel" aria-labelledby="myRequestsHeading">
      <div class="sec-head"><h2 id="myRequestsHeading">My requests</h2><button class="btn ghost sm" type="button" id="refreshRequests">Refresh</button></div>
      <div class="request-list" id="myRequests" aria-live="polite"><div class="empty box"><b>Loading requests</b>Your submitted requests will appear here.</div></div>
    </section>
  </section>
</main>
<dialog class="request-detail-dialog" id="requestDetails" aria-labelledby="requestDetailTitle"><article class="request-detail">
  <div class="request-detail-head"><div><h2 id="requestDetailTitle"></h2><span class="status-badge" id="requestDetailStatus"></span></div><button class="request-detail-close" type="button" data-close-detail aria-label="Close details">×</button></div>
  <dl class="request-detail-grid" id="requestDetailFields"></dl><div class="request-message" id="requestDetailMessage"></div>
  <div class="request-detail-actions"><button class="btn ghost" type="button" data-close-detail>Close</button></div>
</article></dialog>
<script src="request-portal.js" defer></script>
</body>
</html>
