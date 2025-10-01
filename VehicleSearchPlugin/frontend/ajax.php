<?php
/**
 * Vehicle Search Plugin AJAX Endpoint
 * 
 * @package VehicleSearchPlugin
 * @author Bremer Sitzbezüge
 * @version 1.1.0
 */

require_once PFAD_ROOT . 'includes/globalinclude.php';
require_once PFAD_ROOT . 'plugins/VehicleSearchPlugin/includes/VehicleSearchPlugin.php';

// Initialize plugin
$plugin = new VehicleSearchPlugin();

// Set JSON header
header('Content-Type: application/json');

// Check if request is AJAX
if (!isset($_SERVER['HTTP_X_REQUESTED_WITH']) || 
    strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) !== 'xmlhttprequest') {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid request']);
    exit;
}

// Check CSRF token
if (!isset($_POST['csrf_token']) || !$plugin->validateCSRFToken($_POST['csrf_token'])) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => 'Invalid CSRF token']);
    exit;
}

// Get action
$action = $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'getManufacturers':
            $manufacturers = $plugin->getManufacturers();
            echo json_encode(['success' => true, 'manufacturers' => $manufacturers]);
            break;
            
        case 'getVehicleModels':
            $manufacturerId = (int)($_POST['manufacturer_id'] ?? 0);
            if ($manufacturerId <= 0) {
                throw new Exception('Invalid manufacturer ID');
            }
            
            $models = $plugin->getVehicleModelsByManufacturer($manufacturerId);
            echo json_encode(['success' => true, 'models' => $models]);
            break;
            
        case 'getVehicleTypes':
            $modelName = trim($_POST['model_name'] ?? '');
            if (empty($modelName)) {
                throw new Exception('Invalid model name');
            }
            
            $types = $plugin->getVehicleTypesByModel($modelName);
            echo json_encode(['success' => true, 'types' => $types]);
            break;
            
        case 'getCategories':
            $categories = $plugin->getCategories();
            echo json_encode(['success' => true, 'categories' => $categories]);
            break;
            
        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
