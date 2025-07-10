<?php
// Server Forge CMS - Database Setup Script

// IMPORTANT: For security, this file should be deleted after successful setup.

// Database credentials (without connecting to a specific database yet)
$db_host = 'localhost';
$db_user = 'your_db_user'; // The user needs to create this user and grant privileges
$db_pass = 'your_db_password';
$db_name = 'server_forge_cms';

echo "<h1>Server Forge CMS Setup</h1>";

try {
    // Connect to MySQL server
    $pdo = new PDO("mysql:host=$db_host", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Create the database
    $pdo->exec("CREATE DATABASE IF NOT EXISTS `$db_name` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
    $pdo->exec("USE `$db_name`;");
    echo "<p>Database '<strong>$db_name</strong>' created or already exists.</p>";

    // SQL to create tables
    $sql = "
    CREATE TABLE IF NOT EXISTS `users` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `username` varchar(50) NOT NULL,
      `password` varchar(255) NOT NULL,
      `email` varchar(100) NOT NULL,
      `user_level` tinyint(1) NOT NULL DEFAULT '0',
      `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),
      UNIQUE KEY `username` (`username`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS `news` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `user_id` int(11) NOT NULL,
      `title` varchar(255) NOT NULL,
      `content` text NOT NULL,
      `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),
      KEY `user_id` (`user_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS `forums` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(255) NOT NULL,
      `description` text,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS `forum_topics` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `forum_id` int(11) NOT NULL,
      `user_id` int(11) NOT NULL,
      `title` varchar(255) NOT NULL,
      `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),
      KEY `forum_id` (`forum_id`),
      KEY `user_id` (`user_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS `forum_posts` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `topic_id` int(11) NOT NULL,
      `user_id` int(11) NOT NULL,
      `content` text NOT NULL,
      `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),
      KEY `topic_id` (`topic_id`),
      KEY `user_id` (`user_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS `pages` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `slug` varchar(100) NOT NULL,
      `title` varchar(255) NOT NULL,
      `content` longtext,
      `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),
      UNIQUE KEY `slug` (`slug`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ";

    // Execute the SQL
    $pdo->exec($sql);
    echo "<p>All tables created successfully!</p>";

    // Ask to install demo content
    if (!isset($_GET['install_demo'])) {
        echo "<h2>Install Demo Content?</h2>";
        echo "<p>Do you want to install a default 'admin' user (password: 'admin') and some example content?</p>";
        echo "<p><a href='setup.php?install_demo=yes'>Yes, install demo content</a> | <a href='setup.php?install_demo=no'>No, finish setup</a></p>";
    } else {
        if ($_GET['install_demo'] === 'yes') {
            // Insert demo content
            $admin_pass = password_hash('admin', PASSWORD_DEFAULT);
            $pdo->exec("INSERT INTO `users` (`username`, `password`, `email`, `user_level`) VALUES ('admin', '$admin_pass', 'admin@example.com', 1);");
            $pdo->exec("INSERT INTO `news` (`user_id`, `title`, `content`) VALUES (1, 'Welcome to Server Forge!', 'Your new clan homepage is ready. You can post news, manage servers, and build your community.');");
            $pdo->exec("INSERT INTO `pages` (`slug`, `title`, `content`) VALUES ('about-us', 'About Us', '<h1>About Our Clan</h1><p>This is a custom page you can edit from the admin panel.</p>');");
            echo "<p>Demo content installed successfully!</p>";
        }
        echo "<h2>Setup Complete!</h2>";
        echo "<p style='color:red;'><strong>IMPORTANT: Please delete this file (setup.php) now!</strong></p>";
    }

} catch(PDOException $e){
    die("ERROR: Could not execute setup. " . $e->getMessage());
}
?>