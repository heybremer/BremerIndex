<?php
/**
 * Vehicle Search Plugin Admin Settings
 * 
 * @package VehicleSearchPlugin
 * @author Bremer Sitzbezüge
 * @version 1.1.0
 */

require_once PFAD_ROOT . 'admin/includes/admininclude.php';
require_once PFAD_ROOT . 'plugins/VehicleSearchPlugin/includes/VehicleSearchPlugin.php';

$plugin = new VehicleSearchPlugin();
$error = '';
$success = '';

// Handle form submission
if ($_POST) {
    try {
        $plugin->setConfig('enable_ajax', $_POST['enable_ajax'] ?? '0');
        $plugin->setConfig('default_search_type', $_POST['default_search_type'] ?? 'M');
        $plugin->setConfig('max_results_per_page', (int)($_POST['max_results_per_page'] ?? 20));
        $plugin->setConfig('enable_manufacturer_filter', $_POST['enable_manufacturer_filter'] ?? '0');
        $plugin->setConfig('enable_model_filter', $_POST['enable_model_filter'] ?? '0');
        $plugin->setConfig('enable_type_filter', $_POST['enable_type_filter'] ?? '0');
        $plugin->setConfig('enable_category_filter', $_POST['enable_category_filter'] ?? '0');
        $plugin->setConfig('cache_duration', (int)($_POST['cache_duration'] ?? 3600));
        $plugin->setConfig('show_vehicle_images', $_POST['show_vehicle_images'] ?? '0');
        $plugin->setConfig('enable_advanced_search', $_POST['enable_advanced_search'] ?? '0');
        
        $success = 'Settings saved successfully!';
    } catch (Exception $e) {
        $error = 'Error saving settings: ' . $e->getMessage();
    }
}

// Get current configuration
$config = [
    'enable_ajax' => $plugin->getConfig('enable_ajax', '1'),
    'default_search_type' => $plugin->getConfig('default_search_type', 'M'),
    'max_results_per_page' => $plugin->getConfig('max_results_per_page', '20'),
    'enable_manufacturer_filter' => $plugin->getConfig('enable_manufacturer_filter', '1'),
    'enable_model_filter' => $plugin->getConfig('enable_model_filter', '1'),
    'enable_type_filter' => $plugin->getConfig('enable_type_filter', '1'),
    'enable_category_filter' => $plugin->getConfig('enable_category_filter', '1'),
    'cache_duration' => $plugin->getConfig('cache_duration', '3600'),
    'show_vehicle_images' => $plugin->getConfig('show_vehicle_images', '1'),
    'enable_advanced_search' => $plugin->getConfig('enable_advanced_search', '1')
];

$smarty = new Smarty();
$smarty->assign('config', $config);
$smarty->assign('error', $error);
$smarty->assign('success', $success);
$smarty->assign('pluginUrl', $plugin->getPluginUrl());

echo $smarty->fetch('adminmenu/vehicle_search_settings.tpl');
?>
