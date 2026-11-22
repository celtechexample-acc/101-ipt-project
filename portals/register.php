<?php
declare(strict_types=1);

require_once __DIR__ . '/../php-connections/auth.php';

$error = $_GET['error'] ?? '';
$allowedErrors = ['name', 'email', 'password', 'exists', 'csrf'];
if (!in_array($error, $allowedErrors, true)) {
    $error = '';
}

$name = htmlspecialchars(is_string($_GET['name'] ?? null) ? $_GET['name'] : '', ENT_QUOTES, 'UTF-8');
$email = htmlspecialchars(is_string($_GET['email'] ?? null) ? $_GET['email'] : '', ENT_QUOTES, 'UTF-8');
$csrfToken = htmlspecialchars(csrf_token(), ENT_QUOTES, 'UTF-8');
$messages = [
    'name' => 'Enter a name of 1 to 100 characters.',
    'email' => 'Enter a valid email address (up to 254 characters).',
    'password' => 'Use a password between 8 and 4096 characters.',
    'exists' => 'An account with that name or email already exists.',
    'csrf' => 'Your form session expired. Refresh the page and try again.',
];
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>OSSA Portal – Create account</title>
<link rel="stylesheet" href="../css-folder/login-assa.css">
</head>
<body>
<main class="card">
  <div class="brand">
    <img src="../logo/image/icons/converted.png" alt="CELTECH logo" class="logo">
    <div><b>CELTECH COLLEGE OLONGAPO</b><small>Office of Student Affairs</small></div>
  </div>
  <div class="portal-tag">OSSA Portal</div>
  <form action="../php-connections/register.php" method="post">
    <h1>Create account</h1>
    <?php if ($error !== ''): ?>
      <div class="banner show" role="alert"><?= htmlspecialchars($messages[$error], ENT_QUOTES, 'UTF-8') ?></div>
    <?php endif; ?>
    <input type="hidden" name="csrf_token" value="<?= $csrfToken ?>">

    <div class="field">
      <label class="t" for="name">Name</label>
      <input type="text" id="name" name="name" value="<?= $name ?>" maxlength="100" autocomplete="name" required>
    </div>
    <div class="field">
      <label class="t" for="email">Email</label>
      <input type="email" id="email" name="email" value="<?= $email ?>" maxlength="254" autocomplete="email" required>
    </div>
    <div class="field">
      <label class="t" for="password">Password</label>
      <input type="password" id="password" name="password" minlength="8" maxlength="4096" autocomplete="new-password" required>
    </div>
    <button class="btn" type="submit">Register</button>
    <p class="alt">Already registered? <a href="Ossa-login.php">Log in</a></p>
  </form>
</main>
</body>
</html>
