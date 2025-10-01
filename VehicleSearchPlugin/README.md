# Vehicle Search Plugin for JTL Shop

Advanced vehicle search plugin with manufacturer, model, and type selection for JTL Shop e-commerce platform.

## Features

- **Dual Search Modes:**
  - Feature-based search (Manufacturer → Model → Type)
  - Category-based search (Direct category selection)

- **AJAX Functionality:**
  - Dynamic loading of manufacturers
  - Dynamic loading of models based on manufacturer
  - Dynamic loading of vehicle types based on model
  - Dynamic loading of categories

- **JTL Shop Integration:**
  - Uses JTL Shop's Merkmal system
  - CSRF token protection
  - Session management
  - Database integration

- **Admin Panel:**
  - Configuration settings
  - Cache management
  - Statistics view

## Installation

1. Upload the plugin folder to `/plugins/VehicleSearchPlugin/`
2. Go to JTL Shop Admin → Extensions → Plugin Manager
3. Find "Vehicle Search Plugin" and click "Install"
4. Configure settings in Admin → Extensions → Vehicle Search Settings

## Usage

### In Templates

```smarty
{include file='plugins/VehicleSearchPlugin/frontend/templates/vehicle_search.tpl'}
```

### In On-Page Composer

1. Add a "Rich Text" portlet
2. Switch to "Source" mode
3. Add the include statement above

## Configuration

### Admin Settings

- **Enable AJAX:** Enable/disable AJAX functionality
- **Default Search Type:** Set default search mode (Features/Categories)
- **Max Results Per Page:** Limit search results
- **Cache Duration:** Set cache duration in seconds
- **Filter Settings:** Enable/disable specific filters

### Database Tables

The plugin creates the following tables:
- `tplugin_vehicle_search_config` - Plugin configuration
- `tplugin_vehicle_search_cache` - Cache storage
- `tplugin_vehicle_search_stats` - Search statistics

## API Endpoints

### AJAX Endpoints

- `POST /plugins/VehicleSearchPlugin/frontend/ajax.php`
  - `action=getManufacturers` - Get manufacturer list
  - `action=getVehicleModels` - Get models by manufacturer
  - `action=getVehicleTypes` - Get types by model
  - `action=getCategories` - Get category list

### Parameters

- `csrf_token` - CSRF protection token
- `manufacturer_id` - Manufacturer ID for model lookup
- `model_name` - Model name for type lookup

## Customization

### CSS Styling

Override styles in your template:
```css
.vehicle-search-wrapper {
    /* Your custom styles */
}
```

### Template Customization

Copy the template file to your theme directory and modify as needed.

## Requirements

- JTL Shop 5.0.0 or higher
- PHP 7.4 or higher
- MySQL 5.7 or higher

## Support

For support and questions, contact:
- Email: info@bremer-sitzbezuege.de
- Website: https://bremer-sitzbezuege.de

## License

MIT License - see LICENSE file for details.

## Changelog

### Version 1.0.0
- Initial release
- Feature-based search
- Category-based search
- AJAX functionality
- Admin panel
- Cache system
- Statistics tracking
