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

1. Zip the contents of this directory so that the archive contains the folder `VehicleSearchPlugin` with the plugin files inside.
2. Upload the archive through **JTL-Shop 5.4 Plugin Manager** (`Administration → Plugins → Plug-inverwaltung → Hochladen`).
3. Install the plugin and activate it from the manager.
4. Configure settings in **Administration → Plugins → Vehicle Search Settings**.
5. Clear the shop cache so that the new templates and assets are available.

## Usage

### In Templates

```smarty
{include file='plugins/VehicleSearchPlugin/frontend/templates/vehicle_search.tpl'}
```

### In On-Page Composer (JTL Shop 5.4)

1. Add a **"Freitext"** portlet to the desired container.
2. Switch the portlet to **HTML/Quellcode** mode.
3. Paste the include statement above so that the template is rendered inside the portlet.
4. Save the page and publish the draft.

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

- JTL Shop 5.4.0 or higher
- PHP 7.4 or higher
- MySQL 5.7 or higher

## Support

For support and questions, contact:
- Email: info@bremer-sitzbezuege.de
- Website: https://bremer-sitzbezuege.de

## License

MIT License - see LICENSE file for details.

## Changelog

### Version 1.1.0
- Declare official compatibility with JTL Shop 5.4.0.
- Fix AJAX endpoint URLs when the plugin is installed as a packaged plugin.
- Update asset versioning and documentation to reflect the new release.

### Version 1.0.0
- Initial release
- Feature-based search
- Category-based search
- AJAX functionality
- Admin panel
- Cache system
- Statistics tracking
