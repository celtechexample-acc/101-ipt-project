<?php
declare(strict_types=1);

require_once __DIR__ . '/../php-connections/auth.php';

/*
  Ossa-login.php
  Login requests are handled by php-connections/login.php.
*/
$accountCount = (int) $db->query('SELECT COUNT(*) FROM users')->fetchColumn();
$csrfToken = csrf_token();
if ($accountCount === 0) {
    $setupError = is_string($_GET['error'] ?? null) ? $_GET['error'] : '';
    $setupMessages = [
        'setup_name' => 'Enter a full name of 1 to 100 characters.',
        'setup_email' => 'Enter a valid Gmail address.',
        'setup_password' => 'Use a password between 8 and 4096 characters.',
        'setup_confirmation' => 'The passwords do not match.',
        'setup_csrf' => 'Your form session expired. Refresh the page and try again.',
    ];
    if (!isset($setupMessages[$setupError])) {
        $setupError = '';
    }
    $setupName = htmlspecialchars(
        is_string($_GET['name'] ?? null) ? $_GET['name'] : '',
        ENT_QUOTES,
        'UTF-8'
    );
    $setupEmail = htmlspecialchars(
        is_string($_GET['email'] ?? null) ? $_GET['email'] : '',
        ENT_QUOTES,
        'UTF-8'
    );
    $setupCsrf = htmlspecialchars($csrfToken, ENT_QUOTES, 'UTF-8');
    ?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>OSSA Portal – Initial Admin Registration</title>
<link rel="stylesheet" href="../css-folder/osa-dashboard.css">
</head>
<body class="setup-page">
<div class="page-loading" aria-hidden="true"><span></span></div>
<aside class="panel setup-sidebar" inert aria-disabled="true">
  <div class="brand"><div class="logo"><i></i></div><div><b>OSA Portal</b><small>Announcements</small></div></div>
  <nav aria-label="Main menu">
    <span class="setup-nav-item cta">Create announcement</span>
    <span class="setup-nav-item" aria-current="page">Dashboard</span>
    <div class="grp">Requests</div>
    <span class="setup-nav-item">Teacher requests</span>
    <span class="setup-nav-item">Office requests</span>
    <div class="grp">Workflow</div>
    <span class="setup-nav-item">Drafts</span>
    <span class="setup-nav-item">Office confirmation</span>
    <span class="setup-nav-item">Director approval</span>
    <span class="setup-nav-item">Returned for corrections</span>
    <div class="grp">Records</div>
    <span class="setup-nav-item">Published</span>
    <span class="setup-nav-item">Cancelled / suspended</span>
  </nav>
  <div class="spacer"></div>
  <nav aria-label="Account">
    <span class="setup-nav-item">Settings</span>
    <span class="setup-nav-item logout">Log out</span>
  </nav>
</aside>

<main class="setup-main">
  <header class="top panel">
    <div class="hero">
      <div><small>OSA PORTAL</small><h1>Initial administrator setup</h1><p>Create the first administrator account to unlock the portal.</p></div>
    </div>
  </header>
  <section class="panel setup-card" aria-labelledby="setup-title">
    <div class="setup-brand">
      <img src="../logo/image/icons/converted.png" alt="CELTECH logo">
      <div><b>CELTECH COLLEGE OLONGAPO</b><small>Office of Student Affairs</small></div>
    </div>
    <div class="setup-portal-tag">OSSA Portal</div>
    <h2 id="setup-title">Register the first administrator</h2>
    <p class="setup-intro">The sidebar and portal actions stay disabled until this account is registered and authenticated.</p>
    <?php if ($setupError !== ''): ?>
      <div class="setup-error" role="alert"><?= htmlspecialchars($setupMessages[$setupError], ENT_QUOTES, 'UTF-8') ?></div>
    <?php endif; ?>
    <form id="setupForm" action="../php-connections/register.php" method="post">
      <input type="hidden" name="csrf_token" value="<?= $setupCsrf ?>">
      <div class="fld">
        <label for="setup-name">Full Name</label>
        <input type="text" id="setup-name" name="name" value="<?= $setupName ?>" maxlength="100" autocomplete="name" required>
      </div>
      <div class="fld">
        <label for="setup-email">Gmail Address</label>
        <input type="email" id="setup-email" name="email" value="<?= $setupEmail ?>" maxlength="254" autocomplete="email" placeholder="you@gmail.com" required>
      </div>
      <div class="fld">
        <label for="setup-password">Password</label>
        <input type="password" id="setup-password" name="password" minlength="8" maxlength="4096" autocomplete="new-password" required>
      </div>
      <div class="fld">
        <label for="setup-confirmation">Confirm Password</label>
        <input type="password" id="setup-confirmation" name="password_confirmation" minlength="8" maxlength="4096" autocomplete="new-password" required>
      </div>
      <button class="btn green setup-submit" type="submit" data-loading-label="Creating account..."><span class="load-spinner" aria-hidden="true"></span><span data-button-label>Register administrator</span></button>
    </form>
  </section>
</main>
<script>
document.getElementById("setupForm").addEventListener("submit", function (event) {
  var button = this.querySelector('button[type="submit"]');
  if (this.dataset.submitting === "true"){ event.preventDefault(); return; }
  this.dataset.submitting = "true";
  button.disabled = true;
  button.setAttribute("aria-busy", "true");
  button.classList.add("loading");
  button.querySelector("[data-button-label]").textContent = button.dataset.loadingLabel;
  document.body.classList.add("is-submitting");
});
</script>
</body>
</html>
    <?php
    exit;
}

$err   = $_GET['error'] ?? '';
$lockUntil = filter_var($_GET['until'] ?? null, FILTER_VALIDATE_INT);
$lockSeconds = $err === 'locked' && $lockUntil !== false
    ? max(0, $lockUntil - time())
    : 0;
if (!in_array($err, ['both', 'csrf', 'locked', 'setup_completed'], true)
    || ($err === 'locked' && $lockSeconds === 0)) {
    $err = '';
}
$emailValue = is_string($_GET['email'] ?? null) ? $_GET['email'] : '';
$email = htmlspecialchars($emailValue, ENT_QUOTES, 'UTF-8');
$registered = ($_GET['registered'] ?? '') === '1';
$loggedOut = ($_GET['logged_out'] ?? '') === '1';
$success = $registered || $loggedOut;
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>OSSA Portal – Log in</title>
<link rel="stylesheet" href="../css-folder/login-assa.css">
</head>
<body>

<div class="page-loading" aria-hidden="true"><span></span></div>
<div class="blob b1"></div>
<div class="blob b2"></div>

<main class="card">
  <div class="brand">
    <img src="../logo/image/icons/converted.png" alt="CELTECH logo" class="logo">
    <div><b>CELTECH COLLEGE OLONGAPO</b><small>Office of Student Affairs</small></div>
  </div>

  <div class="portal-tag">OSSA Portal</div>

  <form id="loginForm" action="../php-connections/login.php" method="post" novalidate>
    <h1>Welcome back</h1>

    <div class="banner <?= $err !== '' || $success ? 'show' : '' ?> <?= $success ? 'success' : '' ?>" id="banner" role="<?= $success ? 'status' : 'alert' ?>" data-lock-seconds="<?= $err === 'locked' ? $lockSeconds : '' ?>">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v5M12 16.5v.01"/></svg>
      <span id="bannerText"><?php if ($registered): ?>Administrator registered. Log in to continue.<?php elseif ($loggedOut): ?>You have been logged out successfully.<?php elseif ($err === 'setup_completed'): ?>Initial registration is already complete. Please log in.<?php elseif ($err === 'csrf'): ?>Your form session expired. Refresh the page and try again.<?php elseif ($err === 'locked'): ?>Too many failed login attempts. Please try again in <span id="lockoutCountdown"></span>.<?php else: ?>Wrong credentials. Check your email and password.<?php endif; ?></span>
    </div>

    <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken, ENT_QUOTES, 'UTF-8') ?>">

    <!-- EMAIL -->
    <div class="field <?= $err === 'both' ? 'is-error' : '' ?>" id="f-email">
      <label class="t" for="l-email">Email</label>
      <div class="msg" id="m-email" role="alert">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v5M12 16.5v.01"/></svg>
        <span>Wrong email or password.</span>
      </div>
      <input type="email" id="l-email" name="email" value="<?= $email ?>" autocomplete="email" required>
    </div>

    <!-- PASSWORD -->
    <div class="field <?= $err === 'both' ? 'is-error' : '' ?>" id="f-pass">
      <div class="row">
        <label class="t" for="l-pass">Password</label>
        <button type="button" class="linkbtn" id="openForgot">Forgot it?</button>
      </div>
      <div class="msg" id="m-pass" role="alert">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v5M12 16.5v.01"/></svg>
        <span>Wrong email or password.</span>
      </div>
      <div class="pw">
        <input type="password" id="l-pass" name="password" autocomplete="current-password" required>
        <button type="button" class="eye" aria-label="Show password" onclick="togglePw(this)">
          <svg class="shown" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg>
          <svg class="off" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.9 17.9A10.9 10.9 0 0 1 12 19c-6.4 0-10-7-10-7a18 18 0 0 1 5.1-5.9M9.9 5.2A10 10 0 0 1 12 5c6.4 0 10 7 10 7a18 18 0 0 1-2.2 3.2M1 1l22 22"/></svg>
        </button>
      </div>
    </div>

    <button class="btn" type="submit" id="loginBtn" data-loading-label="Logging in..." <?= $err === 'locked' ? 'disabled' : '' ?>><span class="spin"></span><span data-button-label>Log in</span></button>
   
    <p class="note">Need help signing in? call the devloper for debugs.</p>
  </form>
</main>

<!-- FORGOT PASSWORD WIZARD -->
<div class="modal" id="forgot" aria-hidden="true">
  <div class="sheet" role="dialog" aria-modal="true" aria-labelledby="fp-title">
    <button class="x" id="closeForgot" aria-label="Close">&times;</button>
    <div class="steps" id="steps"><i></i><i></i><i></i></div>
    <div class="form-status" id="fp-status" role="status" aria-live="polite"></div>

    <!-- step 1 -->
    <section class="step active" data-step="1">
      <h2 id="fp-title">Reset your password</h2>
      <p class="sub">Enter the email you use for the OSSA Portal. If it matches an account and email delivery is available, a 6-digit code will be sent.</p>
      <div class="field" id="fp-f1" style="margin-bottom:8px">
        <div class="msg"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v5M12 16.5v.01"/></svg><span>Enter a valid email address.</span></div>
        <input type="email" id="fp-email" placeholder="you@email.com" autocomplete="email">
      </div>
      <button class="btn" type="button" data-next="1"><span class="spin"></span><span data-button-label>Send code</span></button>
    </section>

    <!-- step 2 -->
    <section class="step" data-step="2">
      <h2>Check your email</h2>
      <p class="sub">If an account matches <b id="fp-sent"></b> and email delivery is available, a code will be sent. Enter it below if you receive one.</p>
      <div class="field" id="fp-f2" style="margin-bottom:8px">
        <div class="msg"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v5M12 16.5v.01"/></svg><span>Enter all 6 digits.</span></div>
        <div class="code" id="code">
          <input inputmode="numeric" maxlength="1" aria-label="Digit 1">
          <input inputmode="numeric" maxlength="1" aria-label="Digit 2">
          <input inputmode="numeric" maxlength="1" aria-label="Digit 3">
          <input inputmode="numeric" maxlength="1" aria-label="Digit 4">
          <input inputmode="numeric" maxlength="1" aria-label="Digit 5">
          <input inputmode="numeric" maxlength="1" aria-label="Digit 6">
        </div>
      </div>
      <button class="btn" type="button" data-next="2"><span class="spin"></span><span data-button-label>Verify code</span></button>
      <button class="linkbtn back" type="button" data-back="1">Use a different email</button>
    </section>

    <!-- step 3 -->
    <section class="step" data-step="3">
      <h2>Create a new password</h2>
      <p class="sub">Use at least 8 characters.</p>
      <div class="field" id="fp-f3" style="margin-bottom:8px">
        <div class="msg"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v5M12 16.5v.01"/></svg><span id="fp-err3">Passwords don’t match.</span></div>
        <input type="password" id="fp-new" placeholder="New password" autocomplete="new-password" style="margin-bottom:10px">
        <input type="password" id="fp-new2" placeholder="Confirm password" autocomplete="new-password">
        <div class="strength"><span id="bar"></span></div>
        <div class="hint" id="hint">Strength</div>
      </div>
      <button class="btn" type="button" data-next="3"><span class="spin"></span><span data-button-label>Save password</span></button>
    </section>

    <!-- step 4 -->
    <section class="step center" data-step="4">
      <div class="done-mark"><svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg></div>
      <h2>Password updated</h2>
      <p class="sub">You can now log in to the OSSA Portal with your new password.</p>
      <button class="btn" type="button" id="finish">Back to log in</button>
    </section>
  </div>
</div>

<script>
/* ---------- show / hide password ---------- */
function togglePw(btn){
  var input = btn.parentElement.querySelector("input");
  var show = input.type === "password";
  input.type = show ? "text" : "password";
  btn.classList.toggle("on", show);
  btn.setAttribute("aria-label", show ? "Hide password" : "Show password");
}

/* ---------- login form interaction ---------- */
(function(){
  var form   = document.getElementById("loginForm");
  var fEmail = document.getElementById("f-email");
  var fPass  = document.getElementById("f-pass");
  var mEmail = document.querySelector("#m-email span");
  var mPass  = document.querySelector("#m-pass span");
  var banner = document.getElementById("banner");
  var email  = document.getElementById("l-email");
  var pass   = document.getElementById("l-pass");
  var btn    = document.getElementById("loginBtn");
  var lockSeconds = Number(banner.dataset.lockSeconds);
  var lockedUntil = lockSeconds > 0 ? Date.now() + lockSeconds * 1000 : 0;

  function setErr(field, msgEl, text){
    field.classList.remove("is-error");
    void field.offsetWidth;               /* restart the shake */
    if (text) msgEl.textContent = text;
    field.classList.add("is-error");
  }
  function clear(field){
    field.classList.remove("is-error");
    if (!lockedUntil || lockedUntil <= Math.floor(Date.now() / 1000)) banner.classList.remove("show");
  }

  email.addEventListener("input", function(){ clear(fEmail); });
  pass .addEventListener("input", function(){ clear(fPass);  });

  form.addEventListener("submit", function(e){
    if (form.dataset.submitting === "true"){ e.preventDefault(); return; }
    var bad = false;
    if (!email.value.trim() || !email.checkValidity()){
      setErr(fEmail, mEmail, email.value.trim() ? "Enter a valid email address." : "Enter your email."); bad = true;
    }
    if (!pass.value){
      setErr(fPass, mPass, "Enter your password."); bad = true;
    }
    if (bad){ e.preventDefault(); (fEmail.classList.contains("is-error") ? email : pass).focus(); return; }
    form.dataset.submitting = "true";
    btn.classList.add("loading"); btn.disabled = true;
    btn.setAttribute("aria-busy", "true");
    btn.querySelector("[data-button-label]").textContent = btn.dataset.loadingLabel;
    document.body.classList.add("is-submitting");
  });

  /* if the server sent back an error, focus the right field */
  <?php if ($err === 'both'): ?> email.focus();
  <?php endif; ?>
})();

/* ---------- forgot password wizard ---------- */
(function(){
  var modal = document.getElementById("forgot");
  var steps = [].slice.call(modal.querySelectorAll(".step"));
  var dots  = [].slice.call(document.querySelectorAll("#steps i"));
  var cur = 1;

  function go(n){
    cur = n;
    document.getElementById("fp-status").className = "form-status";
    document.getElementById("fp-status").textContent = "";
    steps.forEach(function(s){ s.classList.toggle("active", +s.dataset.step === n); });
    document.getElementById("steps").style.display = n === 4 ? "none" : "flex";
    dots.forEach(function(d,i){ d.classList.toggle("done", i < n); });
    var first = modal.querySelector(".step.active input");
    if (first) setTimeout(function(){ first.focus(); }, 60);
  }
  function open(){
    modal.classList.add("open"); modal.setAttribute("aria-hidden","false");
    document.getElementById("fp-email").value = document.getElementById("l-email").value;
    codeBoxes.forEach(function(input){ input.value = ""; });
    n1.value = ""; n2.value = "";
    go(1);
  }
  function close(){ modal.classList.remove("open"); modal.setAttribute("aria-hidden","true"); }
  function err(id, on){
    var f = document.getElementById(id);
    f.classList.remove("is-error");
    if (on){ void f.offsetWidth; f.classList.add("is-error"); }
  }
  function busy(btn, label){
    var labelEl = btn.querySelector("[data-button-label]");
    var originalLabel = labelEl.textContent;
    btn.classList.add("loading"); btn.disabled = true;
    btn.setAttribute("aria-busy", "true");
    labelEl.textContent = label;
    document.body.classList.add("is-fetching");
    return function(){
      btn.classList.remove("loading"); btn.disabled = false;
      btn.removeAttribute("aria-busy");
      labelEl.textContent = originalLabel;
      document.body.classList.remove("is-fetching");
    };
  }
  function status(message, isError){
    var el = document.getElementById("fp-status");
    el.textContent = message;
    el.className = "form-status show" + (isError ? " error" : " success");
  }
  async function submit(url, values){
    var body = new URLSearchParams(values);
    body.set("csrf_token", document.querySelector('#loginForm input[name="csrf_token"]').value);
    var controller = new AbortController();
    var timeout = setTimeout(function(){ controller.abort(); }, 30000);
    try {
      var response = await fetch(url, {
        method: "POST",
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body.toString(),
        credentials: "same-origin",
        signal: controller.signal
      });
      var result;
      try { result = await response.json(); }
      catch (_) { throw new Error("The server returned an invalid response. Please try again."); }
      if (!response.ok || !result.ok) throw new Error(result.message || "The request could not be completed.");
      return result;
    } catch (error) {
      if (error.name === "AbortError") throw new Error("The request timed out. Please try again.");
      if (error instanceof TypeError) throw new Error("The request failed. Check your connection and try again.");
      throw error;
    } finally {
      clearTimeout(timeout);
    }
  }

  document.getElementById("openForgot").onclick = open;
  document.getElementById("closeForgot").onclick = close;
  document.getElementById("finish").onclick = close;
  modal.addEventListener("click", function(e){ if (e.target === modal) close(); });
  document.addEventListener("keydown", function(e){ if (e.key === "Escape") close(); });

  var email = document.getElementById("fp-email");
  var codeBoxes = [].slice.call(document.querySelectorAll("#code input"));
  var n1 = document.getElementById("fp-new"), n2 = document.getElementById("fp-new2");

  email.addEventListener("input", function(){ err("fp-f1", false); });
  n1.addEventListener("input", function(){
    err("fp-f3", false);
    var v = n1.value, s = 0;
    if (v.length >= 8) s++; if (/[A-Z]/.test(v)) s++; if (/\d/.test(v)) s++; if (/[^A-Za-z0-9]/.test(v)) s++;
    var bar = document.getElementById("bar");
    bar.style.width = (v ? Math.max(s,1) * 25 : 0) + "%";
    bar.style.background = s <= 1 ? "var(--bad)" : s <= 2 ? "#e0a31f" : "var(--g-500)";
    document.getElementById("hint").textContent = !v ? "Strength" : s <= 1 ? "Weak" : s <= 2 ? "Okay" : "Strong";
  });
  n2.addEventListener("input", function(){ err("fp-f3", false); });

  codeBoxes.forEach(function(b,i){
    b.addEventListener("input", function(){
      b.value = b.value.replace(/\D/g,"").slice(0,1);
      err("fp-f2", false);
      if (b.value && codeBoxes[i+1]) codeBoxes[i+1].focus();
    });
    b.addEventListener("keydown", function(e){
      if (e.key === "Backspace" && !b.value && codeBoxes[i-1]) codeBoxes[i-1].focus();
    });
    b.addEventListener("paste", function(e){
      var t = (e.clipboardData.getData("text") || "").replace(/\D/g,"").slice(0,6);
      if (!t) return; e.preventDefault();
      t.split("").forEach(function(c,j){ codeBoxes[j].value = c; });
      codeBoxes[Math.min(t.length,5)].focus();
    });
  });

  modal.querySelectorAll("[data-back]").forEach(function(b){ b.onclick = function(){ go(+b.dataset.back); }; });

  modal.querySelectorAll("[data-next]").forEach(function(b){
    b.onclick = function(){
      var step = +b.dataset.next;
      if (step === 1){
        if (!email.value.trim() || !email.checkValidity()){ err("fp-f1", true); email.focus(); return; }
        var finish = busy(b, "Sending OTP...");
        submit("../php-connections/request-password-reset.php", {email: email.value.trim()})
          .then(function(result){
            document.getElementById("fp-sent").textContent = email.value.trim();
            status(result.message, false);
            go(2);
          })
          .catch(function(error){ status(error.message, true); })
          .finally(finish);
      } else if (step === 2){
        if (codeBoxes.some(function(x){ return !x.value; })){ err("fp-f2", true); return; }
        var code = codeBoxes.map(function(input){ return input.value; }).join("");
        var finish = busy(b, "Verifying code...");
        submit("../php-connections/verify-password-reset.php", {code: code})
          .then(function(){ status("Code verified.", false); go(3); })
          .catch(function(error){ status(error.message, true); })
          .finally(finish);
      } else if (step === 3){
        var m = document.getElementById("fp-err3");
        if (n1.value.length < 8){ m.textContent = "Use at least 8 characters."; err("fp-f3", true); n1.focus(); return; }
        if (n1.value !== n2.value){ m.textContent = "Passwords don’t match."; err("fp-f3", true); n2.focus(); return; }
        var finish = busy(b, "Saving password...");
        submit("../php-connections/reset-password.php", {password: n1.value, password_confirmation: n2.value})
          .then(function(){ go(4); })
          .catch(function(error){ status(error.message, true); })
          .finally(finish);
      }
    };
  });
})();

/* The countdown is a visual hint; login.php enforces the lockout on every request. */
(function(){
  var banner = document.getElementById("banner");
  var remaining = Number(banner.dataset.lockSeconds);
  if (!remaining) return;
  var button = document.getElementById("loginBtn");
  var countdown = document.getElementById("lockoutCountdown");
  var expiresAt = Date.now() + remaining * 1000;
  var timer = null;
  function update(){
    var seconds = Math.max(0, Math.ceil((expiresAt - Date.now()) / 1000));
    if (seconds === 0){
      banner.classList.remove("show");
      button.disabled = false;
      if (timer !== null) clearInterval(timer);
      return;
    }
    countdown.textContent = String(Math.floor(seconds / 60)).padStart(2, "0") + ":" + String(seconds % 60).padStart(2, "0");
  }
  button.disabled = true;
  update();
  if (remaining > 0) timer = setInterval(update, 1000);
})();
</script>
</body>
</html>