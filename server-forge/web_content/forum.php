<?php
require_once 'includes/header.php';
require_once 'config.php';
?>

<div class="forum-container">
    <h2><?php echo $lang['forum_title']; ?></h2>
    <table class="forum-table">
        <thead>
            <tr>
                <th><?php echo $lang['forum_table_forum']; ?></th>
                <th><?php echo $lang['forum_table_topics']; ?></th>
                <th><?php echo $lang['forum_table_posts']; ?></th>
            </tr>
        </thead>
        <tbody>
            <?php
            // In a real application, you would loop through forums from the database
            // For this demo, we will use a placeholder.
            ?>
            <tr>
                <td><a href="view_forum.php?id=1"><?php echo $lang['forum_general_discussion']; ?></a><br><small><?php echo $lang['forum_general_desc']; ?></small></td>
                <td>1</td>
                <td>1</td>
            </tr>
        </tbody>
    </table>
</div>

<?php include('includes/footer.php'); ?>