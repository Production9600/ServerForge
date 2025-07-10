<?php
require_once 'includes/header.php';
require_once 'config.php';
require_once 'includes/users.php';

$errors = [];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = trim($_POST['username']);
    $email = trim($_POST['email']);
    $password = trim($_POST['password']);
    $confirm_password = trim($_POST['confirm_password']);

    if ($password != $confirm_password) {
        $errors[] = $lang['register_error_match'];
    }

    if (empty($errors)) {
        if (register_user($pdo, $username, $password, $email)) {
            header("location: login.php");
            exit;
        } else {
            $errors[] = $lang['register_error_exists'];
        }
    }
}
?>

<div class="form-container">
    <h2><?php echo $lang['register_title']; ?></h2>
    <p><?php echo $lang['register_prompt']; ?></p>
    <?php if(!empty($errors)): ?>
        <div class="error-box">
            <?php foreach($errors as $error): ?>
                <p><?php echo $error; ?></p>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
    <form action="register.php" method="post">
        <div class="form-group">
            <label><?php echo $lang['login_username']; ?></label>
            <input type="text" name="username" required>
        </div>
        <div class="form-group">
            <label><?php echo $lang['register_email']; ?></label>
            <input type="email" name="email" required>
        </div>
        <div class="form-group">
            <label><?php echo $lang['login_password']; ?></label>
            <input type="password" name="password" required>
        </div>
        <div class="form-group">
            <label><?php echo $lang['register_confirm_password']; ?></label>
            <input type="password" name="confirm_password" required>
        </div>
        <div class="form-group">
            <input type="submit" class="btn" value="<?php echo $lang['register_submit']; ?>">
            <input type="reset" class="btn btn-secondary" value="<?php echo $lang['register_reset']; ?>">
        </div>
        <p><?php echo $lang['register_have_account']; ?> <a href="login.php"><?php echo $lang['register_login_here']; ?></a>.</p>
    </form>
</div>

<?php include('includes/footer.php'); ?>