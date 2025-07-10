<?php
// Database Configuration
define('DB_HOST', 'localhost');
define('DB_USER', 'your_db_user'); // Replace with your database user
define('DB_PASS', 'your_db_password'); // Replace with your database password
define('DB_NAME', 'server_forge_cms'); // The name of the database

// Establish a database connection
try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME, DB_USER, DB_PASS);
    // Set the PDO error mode to exception
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e){
    die("ERROR: Could not connect. " . $e->getMessage());
}

// Other application settings can go here
define('SITE_TITLE', 'Server Forge Clan');
define('DEFAULT_THEME', '7d2d'); // Default theme
?>