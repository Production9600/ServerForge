<?php
session_start();
require_once '../config.php';
require_once '../includes/users.php';

// Admin check
if (!is_loggedin() || $_SESSION['username'] !== 'admin' || !isset($_GET['id'])) {
    header("location: ../index.php");
    exit;
}

$id = $_GET['id'];
$sql = "DELETE FROM pages WHERE id = ?";
$pdo->prepare($sql)->execute([$id]);

header("location: index.php");
exit;
?>