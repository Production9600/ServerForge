<?php
require_once 'includes/header.php';
require_once 'config.php';
require_once 'includes/users.php';

// Admin check
if (!is_loggedin() || $_SESSION['username'] !== 'admin') {
    header("location: index.php");
    exit;
}

$page_title = 'Create New Page';
$page = ['id' => '', 'title' => '', 'slug' => '', 'content' => ''];

// Edit mode
if (isset($_GET['id'])) {
    $stmt = $pdo->prepare("SELECT * FROM pages WHERE id = ?");
    $stmt->execute([$_GET['id']]);
    $page = $stmt->fetch();
    if ($page) {
        $page_title = 'Edit Page';
    }
}

// Handle form submission
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $id = $_POST['id'];
    $title = trim($_POST['title']);
    $slug = trim($_POST['slug']);
    $content = $_POST['content']; // Allow HTML

    if (empty($id)) { // Create
        $sql = "INSERT INTO pages (title, slug, content) VALUES (?, ?, ?)";
        $pdo->prepare($sql)->execute([$title, $slug, $content]);
    } else { // Update
        $sql = "UPDATE pages SET title = ?, slug = ?, content = ? WHERE id = ?";
        $pdo->prepare($sql)->execute([$title, $slug, $content, $id]);
    }
    header("location: admin.php");
    exit;
}

?>

<div class="form-container">
    <h2><?php echo $page_title; ?></h2>
    <form action="edit_page.php" method="post">
        <input type="hidden" name="id" value="<?php echo htmlspecialchars($page['id']); ?>">
        <div class="form-group">
            <label>Page Title</label>
            <input type="text" name="title" value="<?php echo htmlspecialchars($page['title']); ?>" required>
        </div>
        <div class="form-group">
            <label>Slug (URL, e.g., 'about-us')</label>
            <input type="text" name="slug" value="<?php echo htmlspecialchars($page['slug']); ?>" required>
        </div>
        <div class="form-group">
            <label>Content (Editor)</label>
            <textarea name="content" rows="15"><?php echo htmlspecialchars($page['content']); ?></textarea>
        </div>
        <div class="form-group">
            <input type="submit" class="btn" value="Save Page">
        </div>
    </form>
</div>

<?php include('includes/footer.php'); ?>