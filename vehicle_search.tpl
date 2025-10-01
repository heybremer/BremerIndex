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

        <!-- Seçim Türü -->
        <div class="form-group">
            <label class="form-label">Seçim Türü:</label>
            <select class="form-select" id="cAuswahltyp" name="cAuswahltyp">
                <option value="M" selected>Özellikler hakkında</option>
                <option value="K">Kategori ağacı aracılığıyla</option>
            </select>
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
    
    // Seçim türü değiştiğinde form davranışını güncelle
    const auswahltypSelect = document.getElementById('cAuswahltyp');
    auswahltypSelect.addEventListener('change', function() {
        const auswahltyp = this.value;
        console.log('Seçim türü değişti:', auswahltyp);
        
        // Seçim türüne göre form davranışını ayarla
        if (auswahltyp === 'K') {
            // Kategori ağacı modu - farklı davranış
            console.log('Kategori ağacı modu aktif');
            switchToCategoryMode();
        } else {
            // Özellikler modu - mevcut davranış
            console.log('Özellikler modu aktif');
            switchToFeatureMode();
        }
    });
    
    // Mod değiştirme fonksiyonları
    function switchToCategoryMode() {
        // Kategori ağacı modu - üretici ve model seçimlerini gizle
        bannerVehicleBrandSelect.style.display = 'none';
        bannerVehicleModelSelect.style.display = 'none';
        bannerVehicleTypeSelect.style.display = 'none';
        
        // Kategori seçimi için yeni alan oluştur
        createCategorySelector();
    }
    
    function switchToFeatureMode() {
        // Özellikler modu - normal davranış
        bannerVehicleBrandSelect.style.display = 'block';
        bannerVehicleModelSelect.style.display = 'block';
        bannerVehicleTypeSelect.style.display = 'block';
        
        // Kategori seçicisini kaldır
        const categorySelector = document.getElementById('categorySelector');
        if (categorySelector) {
            categorySelector.remove();
        }
    }
    
    function createCategorySelector() {
        // Mevcut kategori seçicisini kaldır
        const existingSelector = document.getElementById('categorySelector');
        if (existingSelector) {
            existingSelector.remove();
        }
        
        // Yeni kategori seçici oluştur
        const categoryDiv = document.createElement('div');
        categoryDiv.id = 'categorySelector';
        categoryDiv.className = 'form-group';
        categoryDiv.innerHTML = `
            <label class="form-label">Kategori Seçin:</label>
            <select class="form-select" id="categorySelect" name="kKategorie">
                <option value="">Kategori yükleniyor...</option>
            </select>
        `;
        
        // Form'a ekle
        const form = document.getElementById('vehicleSearchForm');
        const submitButton = document.getElementById('bannerSearchBtn');
        form.insertBefore(categoryDiv, submitButton);
        
        // Kategorileri yükle
        loadCategories();
    }
    
    function loadCategories() {
        const formData = new FormData();
        formData.append('action', 'getCategories');
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
            if (data.success && data.categories) {
                const categorySelect = document.getElementById('categorySelect');
                categorySelect.innerHTML = '<option value="">Kategori seçin...</option>';
                data.categories.forEach(category => {
                    const option = document.createElement('option');
                    option.value = category.value;
                    option.textContent = category.text;
                    categorySelect.appendChild(option);
                });
                
                // Kategori seçimi değiştiğinde
                categorySelect.addEventListener('change', function() {
                    bannerSearchBtn.disabled = !this.value;
                });
            } else {
                console.error('Error loading categories:', data.error);
            }
        })
        .catch(error => {
            console.error('AJAX error:', error);
        });
    }

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
