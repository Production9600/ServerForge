<?php
require_once '../includes/header.php';
require_once '../config.php';
require_once '../includes/users.php';

// Admin check
if (!is_loggedin() || $_SESSION['username'] !== 'admin') {
    header("location: ../index.php");
    exit;
}

// Handle user deletion
if (isset($_GET['delete_id'])) {
    $id = $_GET['delete_id'];
    // Prevent deleting the main admin user
    if ($id != 1) {
        $sql = "DELETE FROM users WHERE id = ?";
        $pdo->prepare($sql)->execute([$id]);
    }
    header("location: manage_users.php");
    exit;
}
?>

<div class="admin-container">
    <h2>Manage Users</h2>
    <table class="forum-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Username</th>
                <th>Email</th>
                <th>Level</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php
            $stmt = $pdo->query("SELECT id, username, email, user_level FROM users ORDER BY id");
            while ($row = $stmt->fetch()) {
                echo "<tr>";
                echo "<td>" . $row['id'] . "</td>";
                echo "<td>" . htmlspecialchars($row['username']) . "</td>";
                echo "<td>" . htmlspecialchars($row['email']) . "</td>";
                echo "<td>" . $row['user_level'] . "</td>";
                echo "<td>";
                if ($row['id'] != 1) { // Can't delete user 1
                    echo "<a href='manage_users.php?delete_id=" . $row['id'] . "' onclick='return confirm(\"Are you sure?\")'>Delete</a>";
                }
                echo "</td>";
                echo "</tr>";
            }
            ?>
        </tbody>
    </table>
</div>

<?php include('../includes/footer.php'); ?>