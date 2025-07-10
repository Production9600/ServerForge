<?php
require_once 'includes/header.php';
require_once 'config.php';

// IMPORTANT: For this to work, the webserver user (e.g., www-data) needs read access 
// to the Server Forge servers directory.
// Example command: sudo setfacl -R -m u:www-data:rx /opt/server-forge/server-forge/servers
$servers_dir = '/opt/server-forge/server-forge/servers';

function get_server_status($server_path) {
    $pid_file = "$server_path/.server.pid";
    if (file_exists($pid_file)) {
        $pid = file_get_contents($pid_file);
        // Check if a process with this PID is running
        if (file_exists("/proc/$pid")) {
            return '<span class="status-online">ONLINE</span>';
        }
    }
    return '<span class="status-offline">OFFLINE</span>';
}
?>

<div class="servers-container">
    <h2><?php echo $lang['servers_title']; ?></h2>
    <p><?php echo $lang['servers_subtitle']; ?></p>
    <div class="server-list">
        <?php
        if (is_dir($servers_dir)) {
            $server_folders = scandir($servers_dir);
            foreach ($server_folders as $server_id) {
                if ($server_id === '.' || $server_id === '..') continue;
                
                $server_path = "$servers_dir/$server_id";
                if (is_dir($server_path)) {
                    $game_type = "Unknown";
                    $conf_path = "$server_path/server.conf";
                    if(file_exists($conf_path)) {
                        $conf = parse_ini_file($conf_path);
                        $game_type = $conf['GAME_TYPE'] ?? 'Unknown';
                    }
                    
                    $status = get_server_status($server_path);

                    echo "<div class='server-item'>";
                    echo "<h3>" . htmlspecialchars($server_id) . "</h3>";
                    echo "<p><strong>" . $lang['servers_game'] . ":</strong> " . htmlspecialchars($game_type) . "</p>";
                    echo "<p><strong>" . $lang['servers_status'] . ":</strong> " . $status . "</p>";
                    echo "</div>";
                }
            }
        } else {
            echo "<p>" . $lang['servers_dir_not_found'] . "</p>";
        }
        ?>
    </div>
</div>

<?php include('includes/footer.php'); ?>