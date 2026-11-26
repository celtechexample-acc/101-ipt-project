'use strict';

(function () {
  var accounts = [
    {email:'teacher@gmail.com', name:'Teacher 1', role:'Teacher', password:'teacher123'},
    {email:'teacher2@gmail.com', name:'Teacher 2', role:'Teacher', password:'teacher123'},
    {email:'officer@gmail.com', name:'Officer 1', role:'Officer', password:'officer123'},
    {email:'officer2@gmail.com', name:'Officer 2', role:'Officer', password:'officer123'}
  ];
  var roleSelect = document.getElementById('loginRole');
  var emailInput = document.getElementById('loginEmail');
  var passwordInput = document.getElementById('loginPassword');
  var message = document.getElementById('loginMessage');
  var passwordStorageKey = 'celtechRequestDemoPasswords';

  function savedPasswords() {
    try { return JSON.parse(localStorage.getItem(passwordStorageKey) || '{}'); }
    catch (_) { return {}; }
  }

  function accountPassword(account) {
    return savedPasswords()[account.email] || account.password;
  }

  function showMessage(text, isError) {
    message.textContent = text;
    message.classList.toggle('is-error', Boolean(isError));
    message.hidden = false;
  }

  function updatePortalBranding() {
    var role = roleSelect.value;
    document.title = role + ' Portal | CELTECH';
    document.getElementById('portalTag').textContent = role + ' Portal';
    document.getElementById('loginTitle').textContent = role + ' Portal';
  }

  roleSelect.addEventListener('change', updatePortalBranding);
  document.getElementById('togglePassword').addEventListener('click', function () {
    var reveal = passwordInput.type === 'password';
    passwordInput.type = reveal ? 'text' : 'password';
    this.textContent = reveal ? 'Hide' : 'Show';
    this.setAttribute('aria-label', reveal ? 'Hide password' : 'Show password');
  });

  document.getElementById('demoLoginForm').addEventListener('submit', function (event) {
    event.preventDefault();
    var email = emailInput.value.trim().toLowerCase();
    var role = roleSelect.value;
    var account = accounts.find(function (item) { return item.email === email; });
    if (!account || account.role !== role || accountPassword(account) !== passwordInput.value) {
      showMessage(account && account.role !== role
        ? 'That account does not belong to the selected portal.'
        : 'Email or password is incorrect.', true);
      return;
    }

    var session = {email:account.email, name:account.name, role:account.role};
    sessionStorage.setItem('celtechRequestDemoSession', JSON.stringify(session));
    window.location.href = account.role === 'Teacher' ? 'teacher-request.php' : 'officer-request.php';
  });

  document.getElementById('forgotPassword').addEventListener('click', function () {
    var email = emailInput.value.trim().toLowerCase();
    var role = roleSelect.value;
    var account = accounts.find(function (item) { return item.email === email && item.role === role; });
    if (!account) {
      showMessage('Enter an email for the selected portal before requesting a reset.', true);
      emailInput.focus();
      return;
    }

    var otp = String(Math.floor(100000 + Math.random() * 900000));
    window.alert('Demo password reset code: ' + otp);
    var enteredOtp = window.prompt('Enter the six-digit demo code.');
    if (enteredOtp === null) return;
    if (enteredOtp.trim() !== otp) {
      showMessage('The demo code did not match. Request a new code to try again.', true);
      return;
    }

    var newPassword = window.prompt('Enter a new password (at least 6 characters).');
    if (newPassword === null) return;
    if (newPassword.length < 6 || newPassword.length > 200) {
      showMessage('Use a password between 6 and 200 characters.', true);
      return;
    }

    var passwords = savedPasswords();
    passwords[account.email] = newPassword;
    localStorage.setItem(passwordStorageKey, JSON.stringify(passwords));
    passwordInput.value = '';
    showMessage('Your demo password was changed in this browser.', false);
  });

  updatePortalBranding();
})();
