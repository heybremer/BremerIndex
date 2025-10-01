<?php
/**
 * Vehicle Search Plugin for JTL Shop
 * 
 * @package VehicleSearchPlugin
 * @author Bremer Sitzbezüge
 * @version 1.1.0
 */

class VehicleSearchPlugin extends Plugin
{
    /**
     * Plugin ID
     */
    const PLUGIN_ID = 'VehicleSearchPlugin';
    
    /**
     * Plugin version
     */
    const VERSION = '1.1.0';
    
    /**
     * Configuration cache
     */
    private static $configCache = [];
    
    /**
     * Constructor
     */
    public function __construct()
    {
        parent::__construct();
        $this->init();
    }
    
    /**
     * Initialize plugin
     */
    private function init()
    {
        // Register hooks
        $this->registerHook('HOOK_HEADER_HTML', 'addHeaderAssets');
        $this->registerHook('HOOK_FOOTER_HTML', 'addFooterAssets');
        
        // Register AJAX endpoints
        $this->registerAjaxEndpoint('getManufacturers', 'ajaxGetManufacturers');
        $this->registerAjaxEndpoint('getVehicleModels', 'ajaxGetVehicleModels');
        $this->registerAjaxEndpoint('getVehicleTypes', 'ajaxGetVehicleTypes');
        $this->registerAjaxEndpoint('getCategories', 'ajaxGetCategories');
    }
    
    /**
     * Add header assets
     */
    public function addHeaderAssets()
    {
        $template = Shop::Smarty();
        $template->assign('pluginPath', $this->getPluginPath());
        $template->assign('pluginUrl', $this->getPluginUrl());
        
        return $template->fetch($this->getPluginPath() . 'frontend/templates/header.tpl');
    }
    
    /**
     * Add footer assets
     */
    public function addFooterAssets()
    {
        $template = Shop::Smarty();
        $template->assign('pluginPath', $this->getPluginPath());
        $template->assign('pluginUrl', $this->getPluginUrl());
        
        return $template->fetch($this->getPluginPath() . 'frontend/templates/footer.tpl');
    }
    
    /**
     * AJAX: Get manufacturers
     */
    public function ajaxGetManufacturers()
    {
        $this->validateAjaxRequest();
        
        try {
            $manufacturers = $this->getManufacturers();
            $this->sendJsonResponse(['success' => true, 'manufacturers' => $manufacturers]);
        } catch (Exception $e) {
            $this->sendJsonResponse(['success' => false, 'error' => $e->getMessage()]);
        }
    }
    
    /**
     * AJAX: Get vehicle models
     */
    public function ajaxGetVehicleModels()
    {
        $this->validateAjaxRequest();
        
        $manufacturerId = (int)($_POST['manufacturer_id'] ?? 0);
        if ($manufacturerId <= 0) {
            $this->sendJsonResponse(['success' => false, 'error' => 'Invalid manufacturer ID']);
        }
        
        try {
            $models = $this->getVehicleModelsByManufacturer($manufacturerId);
            $this->sendJsonResponse(['success' => true, 'models' => $models]);
        } catch (Exception $e) {
            $this->sendJsonResponse(['success' => false, 'error' => $e->getMessage()]);
        }
    }
    
    /**
     * AJAX: Get vehicle types
     */
    public function ajaxGetVehicleTypes()
    {
        $this->validateAjaxRequest();
        
        $modelName = trim($_POST['model_name'] ?? '');
        if (empty($modelName)) {
            $this->sendJsonResponse(['success' => false, 'error' => 'Invalid model name']);
        }
        
        try {
            $types = $this->getVehicleTypesByModel($modelName);
            $this->sendJsonResponse(['success' => true, 'types' => $types]);
        } catch (Exception $e) {
            $this->sendJsonResponse(['success' => false, 'error' => $e->getMessage()]);
        }
    }
    
    /**
     * AJAX: Get categories
     */
    public function ajaxGetCategories()
    {
        $this->validateAjaxRequest();
        
        try {
            $categories = $this->getCategories();
            $this->sendJsonResponse(['success' => true, 'categories' => $categories]);
        } catch (Exception $e) {
            $this->sendJsonResponse(['success' => false, 'error' => $e->getMessage()]);
        }
    }
    
    /**
     * Get manufacturers from database
     */
    private function getManufacturers()
    {
        $cacheKey = 'manufacturers_' . md5('all');
        $cached = $this->getCache($cacheKey);
        if ($cached !== false) {
            return $cached;
        }
        
        $sql = "SELECT h.kHersteller, h.cName, h.cBildpfad
                FROM thersteller h
                INNER JOIN tartikel a ON h.kHersteller = a.kHersteller
                WHERE h.nAktiv = 1 
                AND a.nAktiv = 1
                GROUP BY h.kHersteller, h.cName, h.cBildpfad
                ORDER BY h.cName ASC";
        
        $result = Shop::DB()->executeQuery($sql);
        $manufacturers = [];
        
        while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
            $manufacturers[] = [
                'value' => $row['kHersteller'],
                'text' => $row['cName'],
                'image' => $row['cBildpfad']
            ];
        }
        
        $this->setCache($cacheKey, $manufacturers, 3600);
        return $manufacturers;
    }
    
    /**
     * Get vehicle models by manufacturer
     */
    private function getVehicleModelsByManufacturer($manufacturerId)
    {
        $cacheKey = 'models_' . $manufacturerId;
        $cached = $this->getCache($cacheKey);
        if ($cached !== false) {
            return $cached;
        }
        
        $sql = "SELECT DISTINCT mw.kMerkmalwert, mw.cWert
                FROM tmerkmalwert mw
                INNER JOIN tartikelmerkmal am ON mw.kMerkmalwert = am.kMerkmalwert
                INNER JOIN tartikel a ON am.kArtikel = a.kArtikel
                INNER JOIN thersteller h ON a.kHersteller = h.kHersteller
                WHERE h.kHersteller = :manufacturerId 
                AND mw.kMerkmal = 250
                AND mw.cWert IS NOT NULL 
                AND mw.cWert != '' 
                AND a.nAktiv = 1
                ORDER BY mw.cWert ASC";
        
        $result = Shop::DB()->executeQuery($sql, ['manufacturerId' => $manufacturerId]);
        $models = [];
        
        while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
            $models[] = [
                'value' => $row['cWert'],
                'text' => $row['cWert']
            ];
        }
        
        $this->setCache($cacheKey, $models, 1800);
        return $models;
    }
    
    /**
     * Get vehicle types by model
     */
    private function getVehicleTypesByModel($modelName)
    {
        $cacheKey = 'types_' . md5($modelName);
        $cached = $this->getCache($cacheKey);
        if ($cached !== false) {
            return $cached;
        }
        
        $sql = "SELECT DISTINCT mw.kMerkmalwert, mw.cWert
                FROM tmerkmalwert mw
                INNER JOIN tartikelmerkmal am ON mw.kMerkmalwert = am.kMerkmalwert
                INNER JOIN tartikel a ON am.kArtikel = a.kArtikel
                WHERE mw.kMerkmal = 252
                AND mw.cWert LIKE :modelName
                AND mw.cWert IS NOT NULL 
                AND mw.cWert != '' 
                AND a.nAktiv = 1
                ORDER BY mw.cWert ASC";
        
        $result = Shop::DB()->executeQuery($sql, ['modelName' => '%' . $modelName . '%']);
        $types = [];
        
        while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
            $types[] = [
                'value' => $row['cWert'],
                'text' => $row['cWert']
            ];
        }
        
        $this->setCache($cacheKey, $types, 1800);
        return $types;
    }
    
    /**
     * Get categories
     */
    private function getCategories()
    {
        $cacheKey = 'categories_all';
        $cached = $this->getCache($cacheKey);
        if ($cached !== false) {
            return $cached;
        }
        
        $sql = "SELECT k.kKategorie, k.cName, k.cBeschreibung, k.nSort, k.kOberKategorie
                FROM tkategorie k
                INNER JOIN tkategorieartikel ka ON k.kKategorie = ka.kKategorie
                INNER JOIN tartikel a ON ka.kArtikel = a.kArtikel
                WHERE k.nAktiv = 1 
                AND a.nAktiv = 1
                GROUP BY k.kKategorie, k.cName, k.cBeschreibung, k.nSort, k.kOberKategorie
                ORDER BY k.nSort ASC, k.cName ASC";
        
        $result = Shop::DB()->executeQuery($sql);
        $categories = [];
        
        while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
            $categories[] = [
                'value' => $row['kKategorie'],
                'text' => $row['cName'],
                'description' => $row['cBeschreibung'],
                'parent' => $row['kOberKategorie'],
                'sort' => $row['nSort']
            ];
        }
        
        $this->setCache($cacheKey, $categories, 3600);
        return $categories;
    }
    
    /**
     * Get plugin configuration
     */
    public function getConfig($key, $default = null)
    {
        if (!isset(self::$configCache[$key])) {
            $sql = "SELECT cValue FROM tplugin_vehicle_search_config WHERE cName = :key";
            $result = Shop::DB()->executeQuery($sql, ['key' => $key]);
            $row = $result->fetch(PDO::FETCH_ASSOC);
            self::$configCache[$key] = $row ? $row['cValue'] : $default;
        }
        
        return self::$configCache[$key];
    }
    
    /**
     * Set plugin configuration
     */
    public function setConfig($key, $value)
    {
        $sql = "INSERT INTO tplugin_vehicle_search_config (cName, cValue) 
                VALUES (:key, :value) 
                ON DUPLICATE KEY UPDATE cValue = :value";
        
        Shop::DB()->executeQuery($sql, ['key' => $key, 'value' => $value]);
        self::$configCache[$key] = $value;
    }
    
    /**
     * Get cache data
     */
    private function getCache($key)
    {
        $sql = "SELECT cCacheData FROM tplugin_vehicle_search_cache 
                WHERE cCacheKey = :key AND dExpires > NOW()";
        $result = Shop::DB()->executeQuery($sql, ['key' => $key]);
        $row = $result->fetch(PDO::FETCH_ASSOC);
        
        return $row ? json_decode($row['cCacheData'], true) : false;
    }
    
    /**
     * Set cache data
     */
    private function setCache($key, $data, $duration = 3600)
    {
        $expires = date('Y-m-d H:i:s', time() + $duration);
        $cacheData = json_encode($data);
        
        $sql = "INSERT INTO tplugin_vehicle_search_cache (cCacheKey, cCacheData, dExpires) 
                VALUES (:key, :data, :expires) 
                ON DUPLICATE KEY UPDATE cCacheData = :data, dExpires = :expires";
        
        Shop::DB()->executeQuery($sql, [
            'key' => $key,
            'data' => $cacheData,
            'expires' => $expires
        ]);
    }
    
    /**
     * Validate AJAX request
     */
    private function validateAjaxRequest()
    {
        if (!isset($_SERVER['HTTP_X_REQUESTED_WITH']) || 
            strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) !== 'xmlhttprequest') {
            throw new Exception('Invalid request');
        }
        
        if (!isset($_POST['csrf_token']) || !$this->validateCSRFToken($_POST['csrf_token'])) {
            throw new Exception('Invalid CSRF token');
        }
    }
    
    /**
     * Validate CSRF token
     */
    private function validateCSRFToken($token)
    {
        return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
    }
    
    /**
     * Send JSON response
     */
    private function sendJsonResponse($data)
    {
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }
    
    /**
     * Get plugin path
     */
    private function getPluginPath()
    {
        return PFAD_ROOT . 'plugins/' . self::PLUGIN_ID . '/';
    }
    
    /**
     * Get plugin URL
     */
    private function getPluginUrl()
    {
        return Shop::getURL() . '/plugins/' . self::PLUGIN_ID . '/';
    }
}
