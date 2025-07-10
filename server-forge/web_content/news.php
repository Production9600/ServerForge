<?php
require_once 'includes/header.php';
require_once 'config.php';
require_once 'includes/users.php';

// Handle new post submission
if ($_SERVER["REQUEST_METHOD"] == "POST" && is_loggedin()) {
    $title = trim($_POST['title']);
    $content = trim($_POST['content']);
    $user_id = $_SESSION['id'];

    if (!empty($title) && !empty($content)) {
        $sql = "INSERT INTO news (user_id, title, content) VALUES (:user_id, :title, :content)";
        $stmt = $pdo->prepare($sql);
        $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
        $stmt->bindParam(':title', $title, PDO::PARAM_STR);
        $stmt->bindParam(':content', $content, PDO::PARAM_STR);
        $stmt->execute();
    }
}

include('includes/header.php');
?>

<div class="news-container">
    <h2><?php echo $lang['news_latest']; ?></h2>

    <?php if(is_loggedin()): ?>
    <div class="news-post-form">
        <h3><?php echo $lang['news_post_new']; ?></h3>
        <form action="news.php" method="post">
            <div class="form-group">
                <label><?php echo $lang['news_title']; ?></label>
                <input type="text" name="title" required>
            </div>
            <div class="form-group">
                <label><?php echo $lang['news_content']; ?></label>
                <textarea name="content" rows="5" required></textarea>
            </div>
            <div class="form-group">
                <input type="submit" class="btn" value="<?php echo $lang['news_post_article']; ?>">
            </div>
        </form>
    </div>
    <?php endif; ?>

    <div class="news-articles">
        <?php
        $sql = "SELECT n.id, n.title, n.content, n.created_at, u.username 
                FROM news n 
                JOIN users u ON n.user_id = u.id 
                ORDER BY n.created_at DESC";
        $stmt = $pdo->query($sql);

        while ($row = $stmt->fetch()) {
            echo "<article class='news-article'>";
            echo "<h3>" . htmlspecialchars($row['title']) . "</h3>";
            $posted_by = sprintf($lang['news_posted_by'], htmlspecialchars($row['username']), date('F j, Y', strtotime($row['created_at'])));
            echo "<div class='article-meta'>" . $posted_by . "</div>";
            echo "<div class='article-content'>" . nl2br(htmlspecialchars($row['content'])) . "</div>";
            echo "</article>";
        }
        ?>
    </div>
</div>

<?php include('includes/footer.php'); ?>