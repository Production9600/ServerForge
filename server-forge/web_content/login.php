<?php
require_once 'includes/header.php'; // Header now handles session and language
require_once 'config.php';
require_once 'includes/users.php';

$error = '';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);

    if (login_user($pdo, $username, $password)) {
        header("location: index.php");
        exit;
    } else {
        $error = $lang['login_error'];
    }
}
?>

<div class="form-container">
    <h2><?php echo $lang['login_title']; ?></h2>
    <p><?php echo $lang['login_prompt']; ?></p>
    <?php if($error): ?>
        <div class="error-box"><?php echo $error; ?></div>
    <?php endif; ?>
    <form action="login.php" method="post">
        <div class="form-group">
            <label><?php echo $lang['login_username']; ?></label>
            <input type="text" name="username" required>
        </div>
        <div class="form-group">
            <label><?php echo $lang['login_password']; ?></label>
            <input type="password" name="password" required>
        </div>
        <div class="form-group">
            <input type="submit" class="btn" value="<?php echo $lang['nav_login']; ?>">
        </div>
        <p><?php echo $lang['login_no_account']; ?> <a href="register.php"><?php echo $lang['login_signup_now']; ?></a>.</p>
    </form>
</div>

<?php include('includes/footer.php'); ?>