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
Design: `docs/superpowers/specs/2026-10-29-fase2-ui-design.md` (mappa + foglio persistente), piano: `docs/superpowers/plans/2026-10-29-fase2-ui.md`.
- [x] `LocationService` async con gestione permessi e stato "negato"
- [x] Lista nel foglio + `HomeViewModel` (ordinamento per prezzo o distanza, card "Più economico", raggio 5→10→25 km)
- [x] Mappa con prezzo sul marker, il più economico in verde (niente cluster: pin limitati al raggio, vedi Decisioni)
- [x] Chip carburante / self-servito / ordinamento persistiti in `UserDefaults`
- [x] `StationDetailView` con tutti i prezzi, "Indicazioni" (Apple Maps), data aggiornamento
- [x] `InfoView`: attribuzione MIMIT, licenza, link repo, versione, ritorno al tema di sistema
- [x] Banner "dati più vecchi di 48 h" e stato offline
- [x] Empty state e error state per ogni schermata
- [x] Localizzazione IT/EN completa
- [x] Dark mode e Dynamic Type verificati (interruttore tema rapido in alto a destra)
- [ ] Verifica su dispositivo reale: posizione negata, VoiceOver completo, guida con telefono sul supporto

## Fase 3 — Rilascio
- [x] Icona app (2026-10-30): R + strada + pompa corallo, aspetto chiaro principale. `Fuel/Resources/AppIcon.icon` (Icon Composer, Liquid Glass a livelli, iOS 26+; scuro via `fill-specializations` per livello) e `AppIcon.appiconset` (PNG chiaro/scuro/tinto per iOS 17–18). Sorgenti SVG e livelli in `docs/brand/icon/`; anteprime: `ictool` in `Icon Composer.app/Contents/Executables`
- [x] Screenshot store (2026-10-30): 5 per lingua (IT/EN), iPhone 6,9" con didascalie, in `docs/release/screenshots/` con lo script per rifarli
- [x] Kit di pubblicazione (2026-10-30): descrizioni IT/EN, URL, età, diritti sui contenuti, note per la revisione e checklist in `docs/release/app-store-submission.md`; `ITSAppUsesNonExemptEncryption = false`; versione 1.0.0
- [x] Nome definitivo: **Refyl** (2026-10-30). App Store IT/US: nessuna app con questo nome. TMview (EUIPO, UIBM, WIPO): nessun marchio REFYL; simili REFYLL/REFYLD solo in classi 3/21/35. Rischio noto e accettato dall'utente: suona come "refill", registrato in classe 9/42 (es. EUIPO 018284885 BM Ventures, UIBM REFILL S.R.L.). Prima di depositare il marchio, parere di un consulente. Domini liberi: `refyl.app`, `refyl.it`. Testi per lo store: `docs/release/app-store-listing.md`
- [x] Privacy manifest (`PrivacyInfo.xcprivacy`), privacy policy (`PRIVACY.md`) e risposte per la nutrition label (`docs/release/app-store-privacy.md`: "Data Not Collected"); da inserire in App Store Connect
- [x] Menu carburanti con una riga di spiegazione sotto ogni voce (2026-10-31): `Toggle` nel `Menu` invece di `Picker`, perché solo `Button` e `Toggle` mostrano il secondo `Text` come sottotitolo
- [ ] TestFlight pubblico (serve account Apple Developer: passi in `docs/release/app-store-submission.md`)
- [ ] Pubblicazione App Store

## Backlog (post-MVP)
- [ ] "Cerca in quest'area" quando si sposta la mappa
- [ ] Layout a colonna del dettaglio per le taglie di testo Accessibility (oggi la griglia a 3 colonne si stringe)
- [ ] Focus VoiceOver sul dettaglio quando si apre; età del prezzo nell'etichetta VoiceOver delle righe
- [ ] Preferiti (locale)
- [ ] Storico prezzi per stazione (richiede endpoint storico da `fuel-data`)
- [ ] Widget "stazione più economica vicino a casa"
- [ ] Ricerca per comune/indirizzo
- [ ] CarPlay
- [ ] Apple Watch
- [ ] Prezzi segnalati dagli utenti: servirebbe un backend, contro le regole del progetto (nessun backend, nessun account). Da discutere in una issue prima di qualunque lavoro

## Richieste a fuel-data
- [x] URL di produzione: `https://leixien.github.io/FuelFinder_DATA/stations.json` (GitHub Pages, gzip + ETag)
- [ ] Pubblicare anche una fixture ufficiale ridotta per i test dei client (quella attuale è generata a mano dai CSV del 2026-10-28)
- [x] Mappatura `descCarburante` → `fuel` estesa implementata in `FuelFinder_DATA` (vedi `CONTRACT.md`)
- [x] "Pompe Bianche" e ogni tipo sconosciuto → `altro`
- [x] Nullabilità: i campi stringa sono sempre presenti, mai `null`, eventualmente vuoti (oggi `name` vuoto per ~10 impianti: la UI deve gestirlo)

## Decisioni da confermare
- Nome pubblico "Refyl" e bundle id `com.binarybuilders.refyl` (quello della scheda App Store Connect, definitivo dal primo upload del 2026-11-01) (sovrascrivibile in `Config/Local.xcconfig`); target, scheme e cartelle restano `Fuel` per non toccare progetto e CI.
- Cluster delle annotazioni: non servono. La mappa mostra i distributori dell'area inquadrata, al massimo 150 (prima i prezzi recenti, poi i più economici); card e lista restano sulla ricerca "vicino a te". Scartati: clustering manuale e wrapper UIKit (decisione dell'utente dopo la prova su iPhone, 2026-10-30).
- Tornare al tema di sistema ripresenta il foglio dei risultati: `preferredColorScheme(nil)` non aggiorna un foglio già presentato (limite SwiftUI). Scartato: wrapper UIKit su `overrideUserInterfaceStyle`.
- Liquid Glass (decisione dell'utente, 2026-10-30): minimo iOS 17 invariato; chip, controlli dell'angolo, foglio e "Indicazioni" in Liquid Glass da iOS 26 (`DesignSystem/Glass.swift`), materiale sfocato e foglio opaco sotto. Prezzi e pin restano su superfici piene per la leggibilità in auto. Scartato: alzare il minimo a iOS 26.
- Disponibilità sullo store: proposti tutti i paesi con scheda IT + EN (turisti in Italia con account esteri); alternativa: solo Italia. Stato "trader" del DSA da dichiarare in App Store Connect: scelta dell'utente.
- Prezzo più vecchio di 7 giorni: resta in lista con età in arancione ma non vince la card (decisione dell'utente).

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

- 2026-10-31: mobile-mcp lascia sul simulatore un runner XCTest (`com.mobilenext.devicekit-iosUITests.xctrunner`) che fa bloccare `xcodebuild test`. Prima dei test: `xcrun simctl terminate <udid> com.mobilenext.devicekit-iosUITests.xctrunner`, oppure usare un altro simulatore.

## Blocchi noti
- [x] `stations.json` online dal 2026-10-30: il MIMIT blocca i runner GitHub, quindi `FuelFinder_DATA` scarica dall'homelab del maintainer e GitHub pubblica su Pages. L'app ha dati reali senza `-uiTesting`.
- Banner "dati vecchi" (Fase 2): basarlo su `prices_reference_date`, non su `generated_at` (la pipeline può ripubblicare dati vecchi con un `generated_at` nuovo).
- 2026-10-29/30: Fase 2 UI MVP. Design scelto con mockup (mappa + foglio, stile Apple). 73 unit test + 3 UI test verdi, `swiftlint --strict` pulito. Revisori indipendenti sui task 6–8, correzioni applicate. In locale i simulatori condivisi sparivano a metà sessione: test eseguiti su un simulatore dedicato "FuelFinder iPhone 17" (iOS 27).
