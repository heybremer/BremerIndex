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
            
        case 'getManufacturers':
            $manufacturers = getManufacturers();
            echo json_encode(['success' => true, 'manufacturers' => $manufacturers]);
            break;
            
        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}

/**
 * Get vehicle models by manufacturer ID (JTL Shop Merkmal system)
 */
function getVehicleModelsByManufacturer($manufacturerId) {
    global $DB;
    
    // JTL Shop Merkmal sistemi kullanarak model listesi
    $sql = "SELECT DISTINCT mw.kMerkmalwert, mw.cWert
            FROM tmerkmalwert mw
            INNER JOIN tartikelmerkmal am ON mw.kMerkmalwert = am.kMerkmalwert
            INNER JOIN tartikel a ON am.kArtikel = a.kArtikel
            INNER JOIN thersteller h ON a.kHersteller = h.kHersteller
            WHERE h.kHersteller = :manufacturerId 
            AND mw.kMerkmal = 250  -- Fahrzeug-Modell Merkmal ID
            AND mw.cWert IS NOT NULL 
            AND mw.cWert != '' 
            AND a.nAktiv = 1
            ORDER BY mw.cWert ASC";
    
    $result = $DB->executeQuery($sql, ['manufacturerId' => $manufacturerId]);
    $models = [];
    
    while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
        $models[] = [
            'value' => $row['cWert'],
            'text' => $row['cWert']
        ];
    }
    
    return $models;
}

/**
 * Get vehicle types by model name (JTL Shop Merkmal system)
 */
function getVehicleTypesByModel($modelName) {
    global $DB;
    
    // JTL Shop Merkmal sistemi kullanarak tip listesi
    $sql = "SELECT DISTINCT mw.kMerkmalwert, mw.cWert
            FROM tmerkmalwert mw
            INNER JOIN tartikelmerkmal am ON mw.kMerkmalwert = am.kMerkmalwert
            INNER JOIN tartikel a ON am.kArtikel = a.kArtikel
            WHERE mw.kMerkmal = 252  -- Fahrzeug-Typ Merkmal ID
            AND mw.cWert LIKE :modelName
            AND mw.cWert IS NOT NULL 
            AND mw.cWert != '' 
            AND a.nAktiv = 1
            ORDER BY mw.cWert ASC";
    
    $result = $DB->executeQuery($sql, ['modelName' => '%' . $modelName . '%']);
    $types = [];
    
    while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
        $types[] = [
            'value' => $row['cWert'],
            'text' => $row['cWert']
        ];
    }
    
    return $types;
}

/**
 * Get manufacturers (JTL Shop Hersteller)
 */
function getManufacturers() {
    global $DB;
    
    $sql = "SELECT h.kHersteller, h.cName, h.cBildpfad
            FROM thersteller h
            INNER JOIN tartikel a ON h.kHersteller = a.kHersteller
            WHERE h.nAktiv = 1 
            AND a.nAktiv = 1
            GROUP BY h.kHersteller, h.cName, h.cBildpfad
            ORDER BY h.cName ASC";
    
    $result = $DB->executeQuery($sql);
    $manufacturers = [];
    
    while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
        $manufacturers[] = [
            'value' => $row['kHersteller'],
            'text' => $row['cName'],
            'image' => $row['cBildpfad']
        ];
    }
    
    return $manufacturers;
}

/**
 * Validate CSRF token
 */
function validateCSRFToken($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}
?>
