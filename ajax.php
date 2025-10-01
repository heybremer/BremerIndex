<?php
/**
 * JTL Shop AJAX Endpoint for Vehicle Search
 * This file handles AJAX requests for vehicle model and type loading
 */

// JTL Shop includes
require_once 'includes/globalinclude.php';

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
if (!isset($_POST['csrf_token']) || !validateCSRFToken($_POST['csrf_token'])) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => 'Invalid CSRF token']);
    exit;
}

// Get action
$action = $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'getVehicleModels':
            $manufacturerId = (int)($_POST['manufacturer_id'] ?? 0);
            if ($manufacturerId <= 0) {
                throw new Exception('Invalid manufacturer ID');
            }
            
            $models = getVehicleModelsByManufacturer($manufacturerId);
            echo json_encode(['success' => true, 'models' => $models]);
            break;
            
        case 'getVehicleTypes':
            $modelName = trim($_POST['model_name'] ?? '');
            if (empty($modelName)) {
                throw new Exception('Invalid model name');
            }
            
            $types = getVehicleTypesByModel($modelName);
            echo json_encode(['success' => true, 'types' => $types]);
            break;
            
        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}

/**
 * Get vehicle models by manufacturer ID
 */
function getVehicleModelsByManufacturer($manufacturerId) {
    global $DB;
    
    $sql = "SELECT DISTINCT cModell 
            FROM tfahrzeugmodell 
            WHERE kHersteller = :manufacturerId 
            AND cModell IS NOT NULL 
            AND cModell != '' 
            ORDER BY cModell ASC";
    
    $result = $DB->executeQuery($sql, ['manufacturerId' => $manufacturerId]);
    $models = [];
    
    while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
        $models[] = [
            'value' => $row['cModell'],
            'text' => $row['cModell']
        ];
    }
    
    return $models;
}

/**
 * Get vehicle types by model name
 */
function getVehicleTypesByModel($modelName) {
    global $DB;
    
    $sql = "SELECT DISTINCT cFahrzeugtyp 
            FROM tfahrzeugmodell 
            WHERE cModell = :modelName 
            AND cFahrzeugtyp IS NOT NULL 
            AND cFahrzeugtyp != '' 
            ORDER BY cFahrzeugtyp ASC";
    
    $result = $DB->executeQuery($sql, ['modelName' => $modelName]);
    $types = [];
    
    while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
        $types[] = [
            'value' => $row['cFahrzeugtyp'],
            'text' => $row['cFahrzeugtyp']
        ];
    }
    
    return $types;
}

/**
 * Validate CSRF token
 */
function validateCSRFToken($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}
?>
