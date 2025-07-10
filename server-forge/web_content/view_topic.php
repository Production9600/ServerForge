<?php
require_once 'includes/header.php';
require_once 'config.php';

// For this demo, we'll use placeholder content.
$topic_title = $lang['forum_welcome_topic'];
?>

<div class="forum-container">
    <h2><?php echo htmlspecialchars($topic_title); ?></h2>
    
    <div class="post-container">
        <div class="post">
            <div class="post-author">Admin</div>
            <div class="post-content">
                <p><?php echo $lang['forum_welcome_post']; ?></p>
            </div>
        </div>
    </div>

    <?php if(is_loggedin()): ?>
    <div class="reply-form">
        <h3><?php echo $lang['forum_post_reply']; ?></h3>
        <form action="view_topic.php?id=1" method="post">
            <div class="form-group">
                <textarea name="content" rows="5" required></textarea>
            </div>
            <div class="form-group">
                <input type="submit" class="btn" value="<?php echo $lang['forum_post_reply']; ?>">
            </div>
        </form>
    </div>
    <?php endif; ?>
</div>

<?php include('includes/footer.php'); ?>