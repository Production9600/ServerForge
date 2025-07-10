<?php
// Start session if not already started
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

// Define a root path for includes if not already defined
if (!defined('ROOT_PATH')) {
    define('ROOT_PATH', dirname(__DIR__) . '/');
}

require_once ROOT_PATH . 'includes/functions.php';

// Load language
// In a real app, this could be set from user profile or session
$lang_code = $_SESSION['lang'] ?? 'en';
$lang = load_language($lang_code);

?>
<!DOCTYPE html>
<html lang="<?php echo $lang_code; ?>">
<head>
    <meta charset="UTF-8">
    <title><?php echo get_config(null, 'site_title'); ?></title>
    <?php
        // Theme switcher logic
        $theme = $_SESSION['theme'] ?? get_config(null, 'default_theme') ?? '7d2d';
        $theme_path = 'themes/' . $theme . '/style.css';
        if (!file_exists(ROOT_PATH . $theme_path)) {
            $theme_path = 'themes/7d2d/style.css'; // Fallback
        }
    ?>
    <link rel="stylesheet" href="<?php echo $theme_path; ?>">
</head>
<body>

<div class="container">
    <header class="main-header" style="background-image: url('<?php echo 'themes/' . $theme . '/images/header_bg.jpg'; ?>');">
        <div class="logo">
            <a href="index.php">
                <img src="<?php echo 'themes/' . $theme . '/images/logo.png'; ?>" alt="Clan Logo" style="max-height: 80px;">
            </a>
        </div>
        <nav class="main-nav">
            <ul>
                <li><a href="<?php echo '/index.php'; ?>"><?php echo $lang['nav_home']; ?></a></li>
                <li><a href="<?php echo '/news.php'; ?>"><?php echo $lang['nav_news']; ?></a></li>
                <li><a href="<?php echo '/servers.php'; ?>"><?php echo $lang['nav_servers']; ?></a></li>
                <li><a href="<?php echo '/forum.php'; ?>"><?php echo $lang['nav_forum']; ?></a></li>
                <?php
                    // Dynamically add custom pages to nav
                    $stmt = $pdo->query("SELECT title, slug FROM pages ORDER BY title");
                    while ($row = $stmt->fetch()) {
                        echo "<li><a href='/page.php?slug=" . htmlspecialchars($row['slug']) . "'>" . htmlspecialchars($row['title']) . "</a></li>";
                    }
                ?>
                <?php if (is_loggedin()): ?>
                    <li><a href="/admin/">Admin</a></li>
                    <li><a href="/auth/logout.php"><?php echo $lang['nav_logout']; ?></a></li>
                <?php else: ?>
                    <li><a href="/auth/login.php"><?php echo $lang['nav_login']; ?></a></li>
                <?php endif; ?>
            </ul>
        </nav>
    </header>
    <main>