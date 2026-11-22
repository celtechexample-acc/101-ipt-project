<?php
declare(strict_types=1);

use PHPMailer\PHPMailer\PHPMailer;

require_once __DIR__ . '/../PHPMailer-master/PHPMailer-master/src/Exception.php';
require_once __DIR__ . '/../PHPMailer-master/PHPMailer-master/src/PHPMailer.php';
require_once __DIR__ . '/../PHPMailer-master/PHPMailer-master/src/SMTP.php';
function send_password_reset_email(string $recipient, string $otp): void
{
    // Read credentials from Windows, Codespaces, or Apache.
    $readConfig = static function (string $name): string|false {
        // Windows and GitHub Codespaces environment variables
        $value = getenv($name);

        if (is_string($value) && $value !== '') {
            return $value;
        }

        // Apache environment variables from XAMPP
        if (function_exists('apache_getenv')) {
            $value = apache_getenv($name);

            if (is_string($value) && $value !== '') {
                return $value;
            }
        }

        // Additional PHP environment fallbacks
        $value = $_SERVER[$name] ?? $_ENV[$name] ?? false;

        return is_string($value) && $value !== '' ? $value : false;
    };

    $senderAddress = $readConfig('OSA_GMAIL_ADDRESS');
    $appPassword = $readConfig('OSA_GMAIL_APP_PASSWORD');

    if (
        !is_string($senderAddress)
        || filter_var($senderAddress, FILTER_VALIDATE_EMAIL) === false
        || !is_string($appPassword)
        || trim($appPassword) === ''
    ) {
        throw new RuntimeException('Gmail SMTP credentials are not configured.');
    }

    $mail = new PHPMailer(true);
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Timeout = 15;
    $mail->Username = trim($senderAddress);
    $mail->Password = str_replace(' ', '', trim($appPassword));
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;
    $mail->CharSet = 'UTF-8';

    $mail->setFrom(trim($senderAddress), 'CELTECH Office of Student Affairs');
    $mail->addAddress($recipient);
    $mail->isHTML(true);

    $mail->Subject = 'CELTECH OSA - Password Reset Verification Code';

    $mail->Body = '<!doctype html><html lang="en"><body style="margin:0;padding:24px;background:#f2faf5;font-family:Arial,sans-serif;color:#0d1f17">'
        . '<table role="presentation" style="max-width:560px;margin:0 auto;background:#fff;border-radius:16px;padding:32px">'
        . '<tr><td><p style="margin:0 0 8px;color:#166a42;font-weight:bold">CELTECH COLLEGE OLONGAPO</p>'
        . '<h1 style="font-size:22px;margin:0 0 20px">Office of Student Affairs</h1>'
        . '<p>Use this verification code to reset your OSSA Portal password:</p>'
        . '<p style="margin:24px 0;text-align:center;font-size:32px;font-weight:bold;letter-spacing:8px;color:#166a42">'
        . htmlspecialchars($otp, ENT_QUOTES, 'UTF-8') . '</p>'
        . '<p>This code expires in <strong>10 minutes</strong>. Do not share it with anyone.</p>'
        . '<p>If you did not request a password reset, you can safely ignore this email.</p>'
        . '<p style="margin-top:28px;color:#5b6e64">CELTECH Office of Student Affairs</p></td></tr></table></body></html>';

    $mail->AltBody = "CELTECH COLLEGE OLONGAPO - Office of Student Affairs\n\n"
        . "Your OSSA Portal password reset verification code is: {$otp}\n\n"
        . "This code expires in 10 minutes. Do not share it with anyone.\n"
        . "If you did not request a password reset, you can safely ignore this email.\n";

    $mail->send();
}
