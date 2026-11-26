<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Teacher Portal | CELTECH</title>
<link rel="stylesheet" href="../css-folder/osa-dashboard.css">
<link rel="stylesheet" href="../css-folder/request-portals.css">
</head>
<body class="login-page" data-login-page>
<main class="portal-login-card panel">
  <div class="portal-brand">
    <img src="../logo/image/icons/converted.png" alt="CELTECH College logo">
    <div><b>CELTECH COLLEGE OLONGAPO</b><small>Office of Student Affairs</small></div>
  </div>
  <div class="fld role-picker">
    <label for="loginRole">Choose portal</label>
    <select id="loginRole" name="role">
      <option value="Teacher">Teacher</option>
      <option value="Officer">Officer</option>
    </select>
  </div>
  <span class="portal-tag" id="portalTag">Teacher Portal</span>
  <h1 id="loginTitle">Teacher Portal</h1>
  <p class="login-intro">Sign in to submit a request to the Office of Student Affairs.</p>
  <form id="demoLoginForm" novalidate>
    <div class="fld">
      <label for="loginEmail">Email</label>
      <input id="loginEmail" name="email" type="email" autocomplete="username" required>
    </div>
    <div class="fld">
      <div class="field-label-row"><label for="loginPassword">Password</label><button class="text-button" type="button" id="forgotPassword">Forgot Password?</button></div>
      <div class="password-field">
        <input id="loginPassword" name="password" type="password" autocomplete="current-password" required>
        <button class="password-toggle" type="button" id="togglePassword" aria-label="Show password">Show</button>
      </div>
    </div>
    <p class="form-message" id="loginMessage" role="status" aria-live="polite" hidden></p>
    <button class="btn green login-submit" type="submit">Log in</button>
  </form>
  <p class="login-footnote">Demonstration account access</p>
</main>
<script src="../js-folder/teacher-officer-login.js" defer></script>
</body>
</html>
