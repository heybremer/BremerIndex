-- Vehicle Search Plugin Installation SQL

-- Plugin configuration table
CREATE TABLE IF NOT EXISTS `tplugin_vehicle_search_config` (
    `kPluginVehicleSearchConfig` int(11) NOT NULL AUTO_INCREMENT,
    `cName` varchar(255) NOT NULL,
    `cValue` text,
    `cDescription` varchar(500) DEFAULT NULL,
    `dCreated` datetime DEFAULT CURRENT_TIMESTAMP,
    `dModified` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`kPluginVehicleSearchConfig`),
    UNIQUE KEY `cName` (`cName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default configuration
INSERT INTO `tplugin_vehicle_search_config` (`cName`, `cValue`, `cDescription`) VALUES
('enable_ajax', '1', 'Enable AJAX functionality'),
('default_search_type', 'M', 'Default search type (M=Features, K=Categories)'),
('max_results_per_page', '20', 'Maximum results per page'),
('enable_manufacturer_filter', '1', 'Enable manufacturer filtering'),
('enable_model_filter', '1', 'Enable model filtering'),
('enable_type_filter', '1', 'Enable vehicle type filtering'),
('enable_category_filter', '1', 'Enable category filtering'),
('cache_duration', '3600', 'Cache duration in seconds'),
('show_vehicle_images', '1', 'Show vehicle images in results'),
('enable_advanced_search', '1', 'Enable advanced search options');

-- Vehicle search cache table
CREATE TABLE IF NOT EXISTS `tplugin_vehicle_search_cache` (
    `kPluginVehicleSearchCache` int(11) NOT NULL AUTO_INCREMENT,
    `cCacheKey` varchar(255) NOT NULL,
    `cCacheData` longtext,
    `dExpires` datetime NOT NULL,
    `dCreated` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`kPluginVehicleSearchCache`),
    UNIQUE KEY `cCacheKey` (`cCacheKey`),
    KEY `dExpires` (`dExpires`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Vehicle search statistics table
CREATE TABLE IF NOT EXISTS `tplugin_vehicle_search_stats` (
    `kPluginVehicleSearchStats` int(11) NOT NULL AUTO_INCREMENT,
    `cSearchType` varchar(10) NOT NULL,
    `cManufacturer` varchar(255) DEFAULT NULL,
    `cModel` varchar(255) DEFAULT NULL,
    `cVehicleType` varchar(255) DEFAULT NULL,
    `kKategorie` int(11) DEFAULT NULL,
    `nResults` int(11) DEFAULT 0,
    `dSearched` datetime DEFAULT CURRENT_TIMESTAMP,
    `cIP` varchar(45) DEFAULT NULL,
    `cUserAgent` text,
    PRIMARY KEY (`kPluginVehicleSearchStats`),
    KEY `dSearched` (`dSearched`),
    KEY `cSearchType` (`cSearchType`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
