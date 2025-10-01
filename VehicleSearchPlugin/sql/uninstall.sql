-- Vehicle Search Plugin Uninstallation SQL

-- Drop plugin tables
DROP TABLE IF EXISTS `tplugin_vehicle_search_stats`;
DROP TABLE IF EXISTS `tplugin_vehicle_search_cache`;
DROP TABLE IF EXISTS `tplugin_vehicle_search_config`;

-- Remove plugin files (handled by JTL Shop automatically)
-- Remove template files (handled by JTL Shop automatically)
