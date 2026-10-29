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
- [ ] `FuelType` enum (allineato a `fuel_types` del contratto)
- [ ] Modelli `Station`, `FuelPrice`, `StationsPayload` (`Codable`, `Sendable`)
- [ ] Fixture `FuelTests/Fixtures/stations_sample.json` (≈ 30 stazioni reali della Campania, schema v1)
- [ ] `StationsDataSource` con URLSession, ETag/`If-None-Match`, gestione `schema_version`
- [ ] `FileCache` (ultimo payload su disco + data download)
- [ ] `StationsRepository` (cache-first, refresh in background, errori tipizzati)
- [ ] `DistanceCalculator` (Haversine) e `StationFilter` (carburante, self/servito, raggio)
- [ ] Test unitari per tutto quanto sopra (copertura ≥ 80 %)

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
- [ ] Definire URL di produzione di `stations.json` e politica di cache/CDN
- [ ] Pubblicare anche una fixture ufficiale ridotta per i test dei client

## Decisioni da confermare
- Nome di lavoro "Fuel" e bundle id `com.leixien.fuel`: provvisori.
- Cluster delle annotazioni: MapKit nativo (`MapKit` clustering via `MKClusterAnnotation` non è esposto in SwiftUI puro) — valutare clustering manuale per zoom level vs. wrapper UIKit.

- Swift 6 language mode (`SWIFT_VERSION = 6.0`) invece di Swift 5.10 + `SWIFT_STRICT_CONCURRENCY = complete`: stesso controllo, ma violazioni come errori. Alternativa scartata perché Xcode 27 / Swift 6.4 è già lo standard.
- Simulatore di riferimento `iPhone 17` (non `iPhone 16`): con Xcode 27 `OS:latest` è iOS 27, dove iPhone 16 non esiste. In CI si sceglie il primo iPhone disponibile.
- `DATA_URL` provvisorio `https://leixien.github.io/fuel-data/stations.json` (GitHub Pages di `fuel-data`), da sostituire quando la pipeline pubblica l'URL reale. Esposto all'app come chiave Info.plist `DataURL`.
- Licenza cambiata da MIT (commit iniziale) ad Apache 2.0 come da `infoProgetto.md`.
- Contatto del Code of Conduct: profilo GitHub del maintainer. Valutare un indirizzo email dedicato.

## Note di sessione
- 2026-10-29: Fase 0 bootstrap (tranne CI non ancora verificata). Build, unit test (Swift Testing), UI smoke test e `swiftlint --strict` verdi su iPhone 17 / iOS 27. Se un test fallisce, `xcodebuild test` può bloccarsi su `simctl diagnose`: usare `-collect-test-diagnostics never` in locale.

## Blocchi noti
- [!] La pipeline `fuel-data` non esiste ancora: fino ad allora i client lavorano sulla fixture locale.
