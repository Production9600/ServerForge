<?php
// User management functions

function register_user($pdo, $username, $password, $email) {
    // Hash the password for security
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    $sql = "INSERT INTO users (username, password, email) VALUES (:username, :password, :email)";

    try {
        $stmt = $pdo->prepare($sql);
        $stmt->bindParam(':username', $username, PDO::PARAM_STR);
        $stmt->bindParam(':password', $hashed_password, PDO::PARAM_STR);
        $stmt->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt->execute();
        return true;
    } catch (PDOException $e) {
        // Check for duplicate entry
        if ($e->errorInfo[1] == 1062) {
            return false; // Username or email already exists
        }
        // For other errors, you might want to log them or handle them differently
        die("Error: " . $e->getMessage());
    }
}

function login_user($pdo, $username, $password) {
    $sql = "SELECT id, username, password FROM users WHERE username = :username";
    
    $stmt = $pdo->prepare($sql);
    $stmt->bindParam(':username', $username, PDO::PARAM_STR);
    $stmt->execute();

    if ($stmt->rowCount() == 1) {
        $user = $stmt->fetch();
        if (password_verify($password, $user['password'])) {
            // Password is correct, start a new session
            session_start();
            
            // Store data in session variables
            $_SESSION["loggedin"] = true;
            $_SESSION["id"] = $user['id'];
            $_SESSION["username"] = $user['username'];                            
            
            return true;
        }
    }
    return false;
}

function is_loggedin() {
    return isset($_SESSION["loggedin"]) && $_SESSION["loggedin"] === true;
}

function logout_user() {
    // Unset all of the session variables
    $_SESSION = array();
 
    // Destroy the session.
    session_destroy();
 
    // Redirect to login page
    header("location: login.php");
    exit;
}
?>