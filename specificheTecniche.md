# Specifiche tecniche — fuel-ios

## 1. Requisiti di piattaforma

- **Target**: iOS 17.0+ (richiesto per `@Observable`, SwiftData, MapKit SwiftUI con `MapContentBuilder`).
- **Linguaggio**: Swift 5.10+, strict concurrency `complete`.
- **UI**: SwiftUI puro. Nessun UIKit salvo wrapper indispensabili.
- **Xcode**: 16+. Progetto generato con **XcodeGen** (`project.yml` versionato, `.xcodeproj` in `.gitignore`) per evitare conflitti di merge sul project file.
- **Dipendenze esterne**: nessuna nel MVP. Mappe con **MapKit** (gratuito, nessuna chiave). Valutare SPM solo se emerge un bisogno concreto.
- **Package manager**: Swift Package Manager, se e quando servirà.

## 2. Architettura

MVVM leggero con `@Observable`, senza framework di terze parti.

```
Fuel/
├── App/
│   ├── FuelApp.swift            # @main, injection dei servizi via Environment
│   └── AppEnvironment.swift     # container dei servizi (DataSource, LocationService)
├── Domain/
│   ├── Models/                  # Station, FuelPrice, FuelType (Codable, Sendable)
│   └── Logic/                   # DistanceCalculator, StationFilter, Sorting
├── Data/
│   ├── Remote/                  # StationsDataSource (URLSession) + contratto JSON
│   ├── Cache/                   # FileCache: ultimo stations.json su disco + ETag
│   └── Repository/              # StationsRepository: orchestra remote + cache
├── Features/
│   ├── Map/                     # MapView, MapViewModel, StationAnnotation
│   ├── Nearby/                  # NearbyListView, NearbyViewModel
│   ├── StationDetail/           # StationDetailView
│   ├── Filters/                 # FuelTypePicker, ServiceModePicker
│   └── Info/                    # InfoView (attribuzione MIMIT, licenza, versione)
├── Services/
│   └── LocationService.swift    # CLLocationManager wrapper async
├── DesignSystem/                # colori, tipografia, componenti riusabili
└── Resources/                   # Assets.xcassets, Localizable.xcstrings
FuelTests/                       # unit test (XCTest / Swift Testing)
FuelUITests/                     # smoke test UI
```

Regole:
- I modelli di dominio sono `struct` immutabili, `Codable` e `Sendable`.
- I ViewModel sono `@Observable @MainActor final class`.
- Nessuna chiamata di rete nelle View: solo tramite repository.
- `LocationService` espone `AsyncStream<CLLocation>`; mai `CLLocationManager` direttamente nelle View.

## 3. Contratto dati (condiviso con fuel-android e fuel-data)

L'app consuma un unico file statico pubblicato dalla pipeline `fuel-data`. URL di produzione da definire (GitHub Pages / release asset / Cloudflare R2); in sviluppo configurabile tramite `xcconfig`.

### 3.1 `stations.json` — schema v1

```json
{
  "schema_version": 1,
  "generated_at": "2026-10-28T06:30:00Z",
  "prices_reference_date": "2026-10-27",
  "source": {
    "name": "MIMIT - Osservaprezzi Carburanti",
    "license": "IODL 2.0",
    "url": "https://www.mimit.gov.it/it/open-data/elenco-dataset/carburanti-prezzi-praticati-e-anagrafica-degli-impianti"
  },
  "fuel_types": ["benzina", "gasolio", "gpl", "metano", "benzina_special", "gasolio_special"],
  "stations": [
    {
      "id": 12092,
      "name": "AGICAM2000",
      "brand": "Shell",
      "operator": "PIPPO FRANCO SRL",
      "type": "altro",
      "address": "VIA MAZZINI 18",
      "city": "PORPETTO",
      "province": "GO",
      "lat": 45.838383,
      "lon": 13.55575,
      "prices": [
        { "fuel": "benzina", "price": 1.789, "self": true,  "updated_at": "2026-10-27T07:35:21Z" },
        { "fuel": "benzina", "price": 1.939, "self": false, "updated_at": "2026-10-27T07:35:21Z" },
        { "fuel": "gasolio", "price": 1.699, "self": true,  "updated_at": "2026-10-27T07:35:21Z" }
      ]
    }
  ]
}
```

Vincoli:
- `id` è l'`idImpianto` MIMIT (chiave stabile, usata anche da OpenStreetMap come `ref:mise`).
- `price` in euro, 3 decimali; per il metano il prezzo è al **kg**, non al litro.
- `fuel` è un enum chiuso normalizzato dalla pipeline; i carburanti "speciali" delle singole bandiere (es. "Blue Diesel", "V-Power") vengono mappati su `benzina_special` / `gasolio_special` con il nome originale in un campo opzionale `label`.
- `type` ∈ `{stradale, autostradale, altro}`.
- Stazioni senza coordinate valide (lat/lon nulle o fuori dall'Italia) sono **escluse** dalla pipeline, non dal client.
- Una modifica incompatibile incrementa `schema_version`; il client rifiuta versioni maggiori di quella supportata con un messaggio esplicito.

### 3.2 Dimensioni attese

~22.000 impianti, ~60–80k righe prezzo. JSON non compresso ≈ 8–12 MB; servito con gzip ≈ 1.5–2 MB. Accettabile per un download giornaliero in background; il client deve usare `If-None-Match`/ETag e cache su disco.

### 3.3 Origine (per capire la pipeline, non per uso diretto nel client)

File CSV MIMIT, pubblicati ogni mattina:
- `anagrafica_impianti_attivi.csv`: idImpianto; Gestore; Bandiera; Tipo Impianto; Nome Impianto; Indirizzo; Comune; Provincia; Latitudine; Longitudine
- `prezzo_alle_8.csv`: idImpianto; descCarburante; prezzo; isSelf (0/1); dtComu (`gg/mm/aaaa hh:mm:ss`)
- Prima riga: `Estrazione del AAAA-MM-GG`, seconda riga: header.
- **Attenzione**: dal 10 febbraio 2026 il MIMIT ha cambiato il separatore di campo (non è più garantito `;`). Verificare sul file reale prima di scrivere parser (al 2026-10-28 è `|`); parser trovati online precedenti a quella data non funzionano.
- Le coordinate sono inserite dai gestori su base volontaria e non sempre verificate: aspettarsi outlier.

## 4. Funzionalità MVP

1. **Mappa** con annotazioni cluster, prezzo visibile sul marker per il carburante selezionato.
2. **Lista "vicino a me"** ordinata per distanza (Haversine, nessuna chiamata di rete), con prezzo self/servito.
3. **Filtro carburante** persistito in `UserDefaults` (default: benzina).
4. **Toggle self/servito** (default: self; se assente mostra servito con badge).
5. **Dettaglio stazione**: tutti i prezzi, indirizzo, bandiera, pulsante "Indicazioni" (apre Apple Maps), data ultimo aggiornamento.
6. **Info**: attribuzione MIMIT (obbligatoria IODL 2.0), licenza codice, link repo, versione build, data dati.
7. **Offline-first**: all'avvio mostra la cache e aggiorna in background; banner se i dati hanno più di 48 h.

Fuori dal MVP (vedi TODO): storico prezzi, notifiche, preferiti, widget, Apple Watch, CarPlay.

## 5. Localizzazione

Italiano come lingua base, inglese come seconda. Stringhe in `Localizable.xcstrings`. Nessuna stringa hardcoded nelle View.

## 6. Test

- Unit test su: parsing JSON (fixture reale ridotta in `FuelTests/Fixtures/`), calcolo distanze, filtri, gestione `schema_version` non supportata, cache/ETag.
- UI test smoke: avvio → lista → dettaglio.
- Target di copertura per `Domain/` e `Data/`: ≥ 80%.

## 7. CI

GitHub Actions (`macos-latest`): `xcodegen generate` → `xcodebuild test -scheme Fuel -destination 'platform=iOS Simulator,name=iPhone 17'` su ogni PR. SwiftLint in modalità strict. Nessun step di firma/archive in CI (la pubblicazione è manuale del maintainer).

## 8. Configurazione e segreti

- `Config/Debug.xcconfig`, `Config/Release.xcconfig` versionati con `DATA_URL`.
- `Config/Local.xcconfig` in `.gitignore` per `DEVELOPMENT_TEAM` e `PRODUCT_BUNDLE_IDENTIFIER` personali (bundle id di default: `com.leixien.fuel`).
- Il repo non deve contenere chiavi, certificati, profili di provisioning o token.

## 9. Privacy

- Posizione: `NSLocationWhenInUseUsageDescription`, richiesta solo quando l'utente apre mappa o lista "vicino a me". Nessun tracciamento, nessuna analytics nel MVP.
- Nessun dato utente lascia il dispositivo: l'unica richiesta di rete è il GET del JSON.
