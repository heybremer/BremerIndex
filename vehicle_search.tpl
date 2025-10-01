{* JTL Shop Template for Vehicle Search Form *}
{* This template should be included in your JTL Shop template *}

{block name='vehicle-search-form'}
<div class="vehicle-search-wrapper">
    <form class="search-form" method="POST" action="{$ShopURL}/index.php" id="vehicleSearchForm">
        <!-- JTL Shop CSRF Token -->
        <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}" />
        <input type="hidden" name="a" value="{$smarty.const.LINKTYP_ARTIKELSUCHE}" />
        <input type="hidden" name="s" value="{$smarty.session.sessionID}" />
        
        <div class="form-group">
            <select class="form-select" id="bannerVehicleBrand" name="cHersteller" required>
                <option value="">Fahrzeug-Marke wählen...</option>
                {* AJAX ile yüklenecek - sayfa yüklendiğinde doldurulacak *}
            </select>
            <label class="form-label">Fahrzeug-Marke</label>
        </div>

        <div class="form-group">
            <select class="form-select" id="bannerVehicleModel" name="cModell" disabled>
                <option value="">Fahrzeug-Modell wählen...</option>
                {if !empty($oModell_arr)}
                    {foreach from=$oModell_arr item=oModell}
                        <option value="{$oModell->cModell}" {if $oModell->cModell == $cModell}selected{/if}>
                            {$oModell->cModell}
                        </option>
                    {/foreach}
                {/if}
            </select>
            <label class="form-label">Fahrzeug-Modell</label>
        </div>

        <div class="form-group">
            <select class="form-select" id="bannerVehicleType" name="cFahrzeugtyp" disabled>
                <option value="">Fahrzeug-Typ wählen...</option>
                {foreach from=$oFahrzeugtyp_arr item=oFahrzeugtyp}
                    <option value="{$oFahrzeugtyp->cFahrzeugtyp}" {if $oFahrzeugtyp->cFahrzeugtyp == $cFahrzeugtyp}selected{/if}>
                        {$oFahrzeugtyp->cFahrzeugtyp}
                    </option>
                {/foreach}
            </select>
            <label class="form-label">Fahrzeug-Typ</label>
        </div>

        <!-- Zusätzliche JTL Shop Parameter -->
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
    
    // Sayfa yüklendiğinde üreticileri yükle
    loadManufacturers();
    
    // Load vehicle models when manufacturer changes
    bannerVehicleBrandSelect.addEventListener('change', function() {
        const manufacturerId = this.value;
        if (manufacturerId) {
            loadVehicleModels(manufacturerId);
        } else {
            bannerVehicleModelSelect.innerHTML = '<option value="">Fahrzeug-Modell wählen...</option>';
            bannerVehicleModelSelect.disabled = true;
            bannerVehicleTypeSelect.innerHTML = '<option value="">Fahrzeug-Typ wählen...</option>';
            bannerVehicleTypeSelect.disabled = true;
            bannerSearchBtn.disabled = true;
        }
    });
    
    // Load vehicle types when model changes
    bannerVehicleModelSelect.addEventListener('change', function() {
        const modelName = this.value;
        if (modelName) {
            loadVehicleTypes(modelName);
        } else {
            bannerVehicleTypeSelect.innerHTML = '<option value="">Fahrzeug-Typ wählen...</option>';
            bannerVehicleTypeSelect.disabled = true;
            bannerSearchBtn.disabled = true;
        }
    });
    
    // Enable search button when all fields are filled
    bannerVehicleTypeSelect.addEventListener('change', function() {
        const vehicleBrand = bannerVehicleBrandSelect.value;
        const vehicleModel = bannerVehicleModelSelect.value;
        const vehicleType = this.value;
        bannerSearchBtn.disabled = !(vehicleBrand && vehicleModel && vehicleType);
    });
    
    // AJAX function to load manufacturers
    function loadManufacturers() {
        const formData = new FormData();
        formData.append('action', 'getManufacturers');
        formData.append('csrf_token', document.querySelector('input[name="csrf_token"]').value);
        
        fetch('{$ShopURL}/ajax.php', {
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
            } else {
                console.error('Error loading manufacturers:', data.error);
            }
        })
        .catch(error => {
            console.error('AJAX error:', error);
        });
    }
    
    // AJAX function to load vehicle models
    function loadVehicleModels(manufacturerId) {
        const formData = new FormData();
        formData.append('action', 'getVehicleModels');
        formData.append('manufacturer_id', manufacturerId);
        formData.append('csrf_token', document.querySelector('input[name="csrf_token"]').value);
        
        fetch('{$ShopURL}/ajax.php', {
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
            } else {
                console.error('Error loading models:', data.error);
                bannerVehicleModelSelect.innerHTML = '<option value="">Fehler beim Laden der Modelle</option>';
            }
        })
        .catch(error => {
            console.error('AJAX error:', error);
            bannerVehicleModelSelect.innerHTML = '<option value="">Fehler beim Laden der Modelle</option>';
        });
    }
    
    // AJAX function to load vehicle types
    function loadVehicleTypes(modelName) {
        const formData = new FormData();
        formData.append('action', 'getVehicleTypes');
        formData.append('model_name', modelName);
        formData.append('csrf_token', document.querySelector('input[name="csrf_token"]').value);
        
        fetch('{$ShopURL}/ajax.php', {
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
            } else {
                console.error('Error loading types:', data.error);
                bannerVehicleTypeSelect.innerHTML = '<option value="">Fehler beim Laden der Typen</option>';
            }
        })
        .catch(error => {
            console.error('AJAX error:', error);
            bannerVehicleTypeSelect.innerHTML = '<option value="">Fehler beim Laden der Typen</option>';
        });
    }
});
</script>
{/block}
