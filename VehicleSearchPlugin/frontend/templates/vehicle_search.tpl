{* Vehicle Search Plugin Template *}
{* This template provides the vehicle search form functionality *}

{block name='vehicle-search-form'}
<div class="vehicle-search-wrapper" id="vehicleSearchPlugin">
    <form class="search-form" method="POST" action="{$ShopURL}/index.php" id="vehicleSearchForm">
        <!-- JTL Shop CSRF Token -->
        <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}" />
        <input type="hidden" name="a" value="{$smarty.const.LINKTYP_ARTIKELSUCHE}" />
        <input type="hidden" name="s" value="{$smarty.session.sessionID}" />
        
        <!-- Search Type Selection -->
        <div class="form-group">
            <label class="form-label">Seçim Türü:</label>
            <select class="form-select" id="cAuswahltyp" name="cAuswahltyp">
                <option value="M" selected>Özellikler hakkında</option>
                <option value="K">Kategori ağacı aracılığıyla</option>
            </select>
        </div>

        <!-- Feature Mode Fields -->
        <div id="featureModeFields">
            <div class="form-group">
                <select class="form-select" id="bannerVehicleBrand" name="cHersteller" required>
                    <option value="">Fahrzeug-Marke wählen...</option>
                </select>
                <label class="form-label">Fahrzeug-Marke</label>
            </div>

            <div class="form-group">
                <select class="form-select" id="bannerVehicleModel" name="cModell" disabled>
                    <option value="">Fahrzeug-Modell wählen...</option>
                </select>
                <label class="form-label">Fahrzeug-Modell</label>
            </div>

            <div class="form-group">
                <select class="form-select" id="bannerVehicleType" name="cFahrzeugtyp" disabled>
                    <option value="">Fahrzeug-Typ wählen...</option>
                </select>
                <label class="form-label">Fahrzeug-Typ</label>
            </div>
        </div>

        <!-- Category Mode Fields -->
        <div id="categoryModeFields" style="display: none;">
            <div class="form-group">
                <select class="form-select" id="categorySelect" name="kKategorie">
                    <option value="">Kategori seçin...</option>
                </select>
                <label class="form-label">Kategori</label>
            </div>
        </div>

        <!-- Additional JTL Shop Parameters -->
        <input type="hidden" name="cSuche" value="1" />
        <input type="hidden" name="nSortierung" value="1" />
        <input type="hidden" name="nSort" value="1" />
        <input type="hidden" name="nSeite" value="1" />
        <input type="hidden" name="nAnzahlProSeite" value="20" />

        <button type="submit" class="search-button" id="bannerSearchBtn" disabled>
            <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"/>
                <path d="m21 21-4.35-4.35"/>
            </svg>
            Suchen
        </button>
    </form>
</div>

{* JavaScript for AJAX functionality *}
<script>
document.addEventListener('DOMContentLoaded', function() {
    const bannerVehicleBrandSelect = document.getElementById('bannerVehicleBrand');
    const bannerVehicleModelSelect = document.getElementById('bannerVehicleModel');
    const bannerVehicleTypeSelect = document.getElementById('bannerVehicleType');
    const bannerSearchBtn = document.getElementById('bannerSearchBtn');
    const auswahltypSelect = document.getElementById('cAuswahltyp');
    const featureModeFields = document.getElementById('featureModeFields');
    const categoryModeFields = document.getElementById('categoryModeFields');
    const categorySelect = document.getElementById('categorySelect');
    
    // Initialize
    loadManufacturers();
    
    // Search type change handler
    auswahltypSelect.addEventListener('change', function() {
        const auswahltyp = this.value;
        
        if (auswahltyp === 'K') {
            // Category mode
            featureModeFields.style.display = 'none';
            categoryModeFields.style.display = 'block';
            loadCategories();
        } else {
            // Feature mode
            featureModeFields.style.display = 'block';
            categoryModeFields.style.display = 'none';
        }
        
        bannerSearchBtn.disabled = true;
    });
    
    // Feature mode event listeners
    bannerVehicleBrandSelect.addEventListener('change', function() {
        const manufacturerId = this.value;
        if (manufacturerId) {
            loadVehicleModels(manufacturerId);
        } else {
            resetModelAndType();
        }
    });
    
    bannerVehicleModelSelect.addEventListener('change', function() {
        const modelName = this.value;
        if (modelName) {
            loadVehicleTypes(modelName);
        } else {
            resetType();
        }
    });
    
    bannerVehicleTypeSelect.addEventListener('change', function() {
        updateSearchButton();
    });
    
    // Category mode event listener
    categorySelect.addEventListener('change', function() {
        updateSearchButton();
    });
    
    // AJAX Functions
    function loadManufacturers() {
        const formData = new FormData();
        formData.append('action', 'getManufacturers');
        formData.append('csrf_token', document.querySelector('input[name="csrf_token"]').value);
        
        fetch('{$PluginUrl}ajax.php', {
            method: 'POST',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success && data.manufacturers) {
                data.manufacturers.forEach(manufacturer => {
                    const option = document.createElement('option');
                    option.value = manufacturer.value;
                    option.textContent = manufacturer.text;
                    bannerVehicleBrandSelect.appendChild(option);
                });
            }
        })
        .catch(error => console.error('Error loading manufacturers:', error));
    }
    
    function loadVehicleModels(manufacturerId) {
        const formData = new FormData();
        formData.append('action', 'getVehicleModels');
        formData.append('manufacturer_id', manufacturerId);
        formData.append('csrf_token', document.querySelector('input[name="csrf_token"]').value);
        
        fetch('{$PluginUrl}ajax.php', {
            method: 'POST',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success && data.models) {
                bannerVehicleModelSelect.innerHTML = '<option value="">Fahrzeug-Modell wählen...</option>';
                data.models.forEach(model => {
                    const option = document.createElement('option');
                    option.value = model.value;
                    option.textContent = model.text;
                    bannerVehicleModelSelect.appendChild(option);
                });
                bannerVehicleModelSelect.disabled = false;
            }
        })
        .catch(error => console.error('Error loading models:', error));
    }
    
    function loadVehicleTypes(modelName) {
        const formData = new FormData();
        formData.append('action', 'getVehicleTypes');
        formData.append('model_name', modelName);
        formData.append('csrf_token', document.querySelector('input[name="csrf_token"]').value);
        
        fetch('{$PluginUrl}ajax.php', {
            method: 'POST',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success && data.types) {
                bannerVehicleTypeSelect.innerHTML = '<option value="">Fahrzeug-Typ wählen...</option>';
                data.types.forEach(type => {
                    const option = document.createElement('option');
                    option.value = type.value;
                    option.textContent = type.text;
                    bannerVehicleTypeSelect.appendChild(option);
                });
                bannerVehicleTypeSelect.disabled = false;
            }
        })
        .catch(error => console.error('Error loading types:', error));
    }
    
    function loadCategories() {
        const formData = new FormData();
        formData.append('action', 'getCategories');
        formData.append('csrf_token', document.querySelector('input[name="csrf_token"]').value);
        
        fetch('{$PluginUrl}ajax.php', {
            method: 'POST',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success && data.categories) {
                categorySelect.innerHTML = '<option value="">Kategori seçin...</option>';
                data.categories.forEach(category => {
                    const option = document.createElement('option');
                    option.value = category.value;
                    option.textContent = category.text;
                    categorySelect.appendChild(option);
                });
            }
        })
        .catch(error => console.error('Error loading categories:', error));
    }
    
    function resetModelAndType() {
        bannerVehicleModelSelect.innerHTML = '<option value="">Fahrzeug-Modell wählen...</option>';
        bannerVehicleModelSelect.disabled = true;
        resetType();
    }
    
    function resetType() {
        bannerVehicleTypeSelect.innerHTML = '<option value="">Fahrzeug-Typ wählen...</option>';
        bannerVehicleTypeSelect.disabled = true;
        updateSearchButton();
    }
    
    function updateSearchButton() {
        const auswahltyp = auswahltypSelect.value;
        let isValid = false;
        
        if (auswahltyp === 'K') {
            // Category mode
            isValid = categorySelect.value !== '';
        } else {
            // Feature mode
            isValid = bannerVehicleBrandSelect.value !== '' && 
                     bannerVehicleModelSelect.value !== '' && 
                     bannerVehicleTypeSelect.value !== '';
        }
        
        bannerSearchBtn.disabled = !isValid;
    }
});
</script>
{/block}
