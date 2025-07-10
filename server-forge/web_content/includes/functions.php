<?php
// Core functions for the Server Forge CMS

// --- Language / Internationalization (i18n) ---

function load_language($lang_code = 'en') {
    $lang_file = ROOT_PATH . 'lang/' . $lang_code . '.php';
    
    // Default to English if the language file doesn't exist
    if (!file_exists($lang_file)) {
        $lang_file = ROOT_PATH . 'lang/en.php';
    }
    
    require($lang_file);
    return $lang; // Return the $lang array
}

// --- User & Session Functions ---

function is_loggedin() {
    return isset($_SESSION["loggedin"]) && $_SESSION["loggedin"] === true;
}

// --- Utility Functions ---

function get_config($pdo, $key) {
    // In a real CMS, you would load settings from a database table
    // For now, we can use a simple placeholder
    $settings = [
        'site_title' => 'Server Forge Clan',
        'default_lang' => 'en'
    ];
    return $settings[$key] ?? null;
}

?>