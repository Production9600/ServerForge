<?php
require_once 'includes/header.php';
require_once 'config.php';

if (!isset($_GET['slug'])) {
    echo "Page not found.";
    exit;
}

$slug = $_GET['slug'];
$stmt = $pdo->prepare("SELECT * FROM pages WHERE slug = ?");
$stmt->execute([$slug]);
$page = $stmt->fetch();

if (!$page) {
    echo "Page not found.";
    exit;
}
?>

<div class="main-content">
    <h2><?php echo htmlspecialchars($page['title']); ?></h2>
    <div>
        <?php echo $page['content']; // Outputting raw HTML content from the editor ?>
    </div>
</div>

<?php include('includes/footer.php'); ?>