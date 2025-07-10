<?php
require_once 'includes/header.php';
require_once 'config.php';

// For this demo, we'll use a placeholder title.
$forum_title = $lang['forum_general_discussion'];
?>

<div class="forum-container">
    <h2><?php echo htmlspecialchars($forum_title); ?></h2>
    <table class="forum-table">
        <thead>
            <tr>
                <th><?php echo $lang['forum_table_topics']; ?></th>
                <th><?php echo $lang['forum_topic_author']; ?></th>
                <th><?php echo $lang['forum_topic_replies']; ?></th>
                <th><?php echo $lang['forum_topic_last_post']; ?></th>
            </tr>
        </thead>
        <tbody>
            <?php
            // In a real application, you would loop through topics from the database.
            ?>
            <tr>
                <td><a href="view_topic.php?id=1"><?php echo $lang['forum_welcome_topic']; ?></a></td>
                <td>Admin</td>
                <td>0</td>
                <td>Just now</td>
            </tr>
        </tbody>
    </table>
    <?php if(is_loggedin()): ?>
        <a href="new_topic.php?forum_id=1" class="btn"><?php echo $lang['forum_new_topic']; ?></a>
    <?php endif; ?>
</div>

<?php include('includes/footer.php'); ?>