<?php
require_once '../includes/header.php';
require_once '../config.php';
require_once '../includes/users.php';

// Simple admin check - in a real app, this would use user levels from the DB
if (!is_loggedin() || $_SESSION['username'] !== 'admin') {
    header("location: ../index.php");
    exit;
}

// Handle theme change
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['theme'])) {
    $theme = basename($_POST['theme']); // Sanitize input
    if (is_dir(ROOT_PATH . 'themes/' . $theme)) {
        $_SESSION['theme'] = $theme;
    }
}
?>

<div class="admin-container">
    <h2>Admin Control Panel</h2>

    <div class="admin-section">
        <h3>Manage Content & Users</h3>
        <ul>
            <li><a href="manage_pages.php">Manage Custom Pages</a></li>
            <li><a href="manage_users.php">Manage Users</a></li>
        </ul>
    </div>

    <div class="admin-section">
        <h3>Theme Selector</h3>
        <form action="index.php" method="post">
            <div class="form-group">
                <label>Select a Theme:</label>
                <select name="theme">
                    <?php
                    $themes = scandir(ROOT_PATH . 'themes');
                    foreach ($themes as $theme_dir) {
                        if ($theme_dir === '.' || $theme_dir === '..') continue;
                        $selected = ($_SESSION['theme'] ?? DEFAULT_THEME) == $theme_dir ? 'selected' : '';
                        echo "<option value='" . htmlspecialchars($theme_dir) . "' $selected>" . htmlspecialchars(ucfirst($theme_dir)) . "</option>";
                    }
                    ?>
                </select>
            </div>
            <div class="form-group">
                <input type="submit" class="btn" value="Apply Theme">
            </div>
        </form>
    </div>
</div>

<?php include('../includes/footer.php'); ?>