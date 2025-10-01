{* Vehicle Search Plugin Admin Settings Template *}

<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">
                        <i class="fas fa-car"></i>
                        Vehicle Search Plugin Settings
                    </h3>
                </div>
                
                <div class="card-body">
                    {if $error}
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-triangle"></i>
                            {$error}
                        </div>
                    {/if}
                    
                    {if $success}
                        <div class="alert alert-success">
                            <i class="fas fa-check-circle"></i>
                            {$success}
                        </div>
                    {/if}
                    
                    <form method="POST" action="">
                        <div class="row">
                            <div class="col-md-6">
                                <h5>General Settings</h5>
                                
                                <div class="form-group">
                                    <label for="enable_ajax">Enable AJAX</label>
                                    <select name="enable_ajax" id="enable_ajax" class="form-control">
                                        <option value="1" {if $config.enable_ajax == '1'}selected{/if}>Yes</option>
                                        <option value="0" {if $config.enable_ajax == '0'}selected{/if}>No</option>
                                    </select>
                                    <small class="form-text text-muted">Enable AJAX functionality for dynamic loading</small>
                                </div>
                                
                                <div class="form-group">
                                    <label for="default_search_type">Default Search Type</label>
                                    <select name="default_search_type" id="default_search_type" class="form-control">
                                        <option value="M" {if $config.default_search_type == 'M'}selected{/if}>Features (Merkmal)</option>
                                        <option value="K" {if $config.default_search_type == 'K'}selected{/if}>Categories</option>
                                    </select>
                                </div>
                                
                                <div class="form-group">
                                    <label for="max_results_per_page">Max Results Per Page</label>
                                    <input type="number" name="max_results_per_page" id="max_results_per_page" 
                                           class="form-control" value="{$config.max_results_per_page}" min="1" max="100">
                                </div>
                                
                                <div class="form-group">
                                    <label for="cache_duration">Cache Duration (seconds)</label>
                                    <input type="number" name="cache_duration" id="cache_duration" 
                                           class="form-control" value="{$config.cache_duration}" min="60" max="86400">
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <h5>Filter Settings</h5>
                                
                                <div class="form-group">
                                    <div class="form-check">
                                        <input type="checkbox" name="enable_manufacturer_filter" id="enable_manufacturer_filter" 
                                               class="form-check-input" value="1" 
                                               {if $config.enable_manufacturer_filter == '1'}checked{/if}>
                                        <label class="form-check-label" for="enable_manufacturer_filter">
                                            Enable Manufacturer Filter
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <div class="form-check">
                                        <input type="checkbox" name="enable_model_filter" id="enable_model_filter" 
                                               class="form-check-input" value="1" 
                                               {if $config.enable_model_filter == '1'}checked{/if}>
                                        <label class="form-check-label" for="enable_model_filter">
                                            Enable Model Filter
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <div class="form-check">
                                        <input type="checkbox" name="enable_type_filter" id="enable_type_filter" 
                                               class="form-check-input" value="1" 
                                               {if $config.enable_type_filter == '1'}checked{/if}>
                                        <label class="form-check-label" for="enable_type_filter">
                                            Enable Vehicle Type Filter
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <div class="form-check">
                                        <input type="checkbox" name="enable_category_filter" id="enable_category_filter" 
                                               class="form-check-input" value="1" 
                                               {if $config.enable_category_filter == '1'}checked{/if}>
                                        <label class="form-check-label" for="enable_category_filter">
                                            Enable Category Filter
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <div class="form-check">
                                        <input type="checkbox" name="show_vehicle_images" id="show_vehicle_images" 
                                               class="form-check-input" value="1" 
                                               {if $config.show_vehicle_images == '1'}checked{/if}>
                                        <label class="form-check-label" for="show_vehicle_images">
                                            Show Vehicle Images
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <div class="form-check">
                                        <input type="checkbox" name="enable_advanced_search" id="enable_advanced_search" 
                                               class="form-check-input" value="1" 
                                               {if $config.enable_advanced_search == '1'}checked{/if}>
                                        <label class="form-check-label" for="enable_advanced_search">
                                            Enable Advanced Search
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row mt-4">
                            <div class="col-12">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save"></i>
                                    Save Settings
                                </button>
                                
                                <a href="{$pluginUrl}adminmenu/clear_cache.php" class="btn btn-warning ml-2">
                                    <i class="fas fa-trash"></i>
                                    Clear Cache
                                </a>
                                
                                <a href="{$pluginUrl}adminmenu/statistics.php" class="btn btn-info ml-2">
                                    <i class="fas fa-chart-bar"></i>
                                    View Statistics
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
