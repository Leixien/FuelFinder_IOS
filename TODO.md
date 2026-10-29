# TODO — fuel-ios

Legenda: `[ ]` da fare · `[~]` in corso · `[x]` fatto · `[!]` bloccato

## Fase 0 — Bootstrap repo
- [x] Documentazione iniziale (CLAUDE.md, infoProgetto.md, specificheTecniche.md, TODO.md)
- [x] `LICENSE` Apache 2.0
- [x] `README.md` con descrizione, screenshot placeholder, istruzioni build (XcodeGen → Xcode → Simulator), attribuzione MIMIT
- [x] `CONTRIBUTING.md` e `CODE_OF_CONDUCT.md`
- [x] `.gitignore` (Xcode, `*.xcodeproj`, `Config/Local.xcconfig`, `xcuserdata`, `DerivedData`)
- [x] `project.yml` XcodeGen: target `Fuel`, `FuelTests`, `FuelUITests`, iOS 17.0, SwiftUI lifecycle
- [x] `Config/Debug.xcconfig`, `Config/Release.xcconfig`, `Config/Local.xcconfig.example`
- [x] `.swiftlint.yml` e `.swiftformat`
- [~] GitHub Actions: build + test + swiftlint su PR (workflow scritto, mai girato: verificare al primo push)
- [x] Issue template (bug / feature) e PR template

## Fase 1 — Dominio e dati
- [x] `FuelType` enum (allineato a `fuel_types` del contratto, incluse le categorie `gnl` e `hvo`)
- [x] Modelli `Station`, `FuelPrice`, `StationsPayload` (`Codable`, `Sendable`)
- [x] Fixture `FuelTests/Fixtures/stations_sample.json` (≈ 30 stazioni reali della Campania, schema v1)
- [x] `StationsDataSource` con URLSession, ETag/`If-None-Match`, gestione `schema_version`
- [x] `FileCache` (ultimo payload su disco + data download)
- [x] `StationsRepository` (cache-first, refresh in background, errori tipizzati)
- [x] `DistanceCalculator` (Haversine) e `StationFilter` (carburante, self/servito, raggio)
- [x] Test unitari per tutto quanto sopra (copertura ≥ 80 %: Domain/Data ~99 %, 30 test)

## Fase 2 — UI MVP
- [ ] `LocationService` async con gestione permessi e stato "negato"
- [ ] `NearbyListView` + ViewModel (ordinamento per distanza, prezzo selezionato in evidenza)
- [ ] `MapView` con annotazioni, cluster e prezzo sul marker
- [ ] `FuelTypePicker` + `ServiceModePicker` persistiti in `UserDefaults`
- [ ] `StationDetailView` con tutti i prezzi, "Indicazioni" (Apple Maps), data aggiornamento
- [ ] `InfoView`: attribuzione MIMIT, licenza, link repo, versione
- [ ] Banner "dati più vecchi di 48 h" e stato offline
- [ ] Empty state e error state per ogni schermata
- [ ] Localizzazione IT/EN completa
- [ ] Dark mode e Dynamic Type verificati

## Fase 3 — Rilascio
- [ ] Icona app e screenshot store
- [ ] Scelta del nome definitivo (verifica disponibilità su App Store e marchi)
- [ ] Privacy manifest (`PrivacyInfo.xcprivacy`) e nutrition label
- [ ] TestFlight pubblico
- [ ] Pubblicazione App Store

## Backlog (post-MVP)
- [ ] Preferiti (locale)
- [ ] Storico prezzi per stazione (richiede endpoint storico da `fuel-data`)
- [ ] Widget "stazione più economica vicino a casa"
- [ ] Ricerca per comune/indirizzo
- [ ] CarPlay
- [ ] Apple Watch

## Richieste a fuel-data
- [x] URL di produzione: `https://leixien.github.io/FuelFinder_DATA/stations.json` (GitHub Pages, gzip + ETag)
- [ ] Pubblicare anche una fixture ufficiale ridotta per i test dei client (quella attuale è generata a mano dai CSV del 2026-10-28)
- [x] Mappatura `descCarburante` → `fuel` estesa implementata in `FuelFinder_DATA` (vedi `CONTRACT.md`)
- [x] "Pompe Bianche" e ogni tipo sconosciuto → `altro`
- [x] Nullabilità: i campi stringa sono sempre presenti, mai `null`, eventualmente vuoti (oggi `name` vuoto per ~10 impianti: la UI deve gestirlo)

## Decisioni da confermare
- Nome di lavoro "Fuel" e bundle id `com.leixien.fuel`: provvisori.
- Cluster delle annotazioni: MapKit nativo (`MapKit` clustering via `MKClusterAnnotation` non è esposto in SwiftUI puro) — valutare clustering manuale per zoom level vs. wrapper UIKit.

- Swift 6 language mode (`SWIFT_VERSION = 6.0`) invece di Swift 5.10 + `SWIFT_STRICT_CONCURRENCY = complete`: stesso controllo, ma violazioni come errori. Alternativa scartata perché Xcode 27 / Swift 6.4 è già lo standard.
- Simulatore di riferimento `iPhone 17` (non `iPhone 16`): con Xcode 27 `OS:latest` è iOS 27, dove iPhone 16 non esiste. In CI si sceglie il primo iPhone disponibile.
- `DATA_URL` = `https://leixien.github.io/FuelFinder_DATA/stations.json`, esposto all'app come chiave Info.plist `DataURL`.
- Licenza cambiata da MIT (commit iniziale) ad Apache 2.0 come da `infoProgetto.md`.
- Contatto del Code of Conduct: profilo GitHub del maintainer. Valutare un indirizzo email dedicato.
- Modelli di dominio solo `Decodable` (non `Codable`): la cache salva i byte grezzi del JSON, quindi l'encoding non serve.
- Decoding tollerante: prezzi con `fuel` sconosciuto vengono scartati e `type` sconosciuto diventa `altro`, così un'aggiunta in `fuel-data` non rende illeggibile l'intero file. Alternativa scartata: decoding rigido (un carburante nuovo = app senza dati).
- Prezzo mostrato: il più basso nella modalità richiesta (più voci `*_special` per stazione); se manca, quello dell'altra modalità (la UI mostrerà il badge confrontando `isSelf`).
- Cache in Application Support esclusa dal backup iCloud, non in Caches (che iOS può svuotare: romperebbe l'offline-first).
- `StationsRepository.refresh()` non deduplica chiamate concorrenti: va chiamato da un solo punto (Fase 2).
- Categorie carburante estese (`gnl`, `hvo`; L-GNC dentro `metano`) invece di esporre le ~60 descrizioni MIMIT: lista stabile e corta per il filtro, nessun prezzo perso grazie a `label`. Scartate: L-GNC come voce separata (per l'utente è lo stesso rifornimento del metano) e un filtro per ogni prodotto commerciale.

## Note di sessione
- 2026-10-29: Fase 0 bootstrap (tranne CI non ancora verificata). Build, unit test (Swift Testing), UI smoke test e `swiftlint --strict` verdi su iPhone 17 / iOS 27. Se un test fallisce, `xcodebuild test` può bloccarsi su `simctl diagnose`: usare `-collect-test-diagnostics never` in locale.
- 2026-10-29: Fase 1 completata. CI verde al primo push. Fixture: 30 stazioni reali di NA/SA/CE/AV/BN dai CSV MIMIT del 2026-10-28 (separatore attuale `|`).

## Blocchi noti
- [!] La pipeline `FuelFinder_DATA` esiste ma il download dal MIMIT può essere bloccato (vedi il suo `TODO.md`): finché `stations.json` non è online l'app non ha dati reali.
- Banner "dati vecchi" (Fase 2): basarlo su `prices_reference_date`, non su `generated_at` (la pipeline può ripubblicare dati vecchi con un `generated_at` nuovo).
