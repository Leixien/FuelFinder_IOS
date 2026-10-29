# CLAUDE.md — fuel-ios

Istruzioni per Claude Code su questo repository. Leggi prima `infoProgetto.md` (contesto), `specificheTecniche.md` (vincoli e contratto dati) e `TODO.md` (stato e prossimi passi), e aggiorna `TODO.md` alla fine di ogni sessione di lavoro.

## Cosa stai costruendo

App iOS nativa SwiftUI, open source, che mostra i prezzi carburante dei distributori italiani leggendo un JSON statico generato dai dati aperti MIMIT. Nessun backend, nessun account, nessuna analytics.

## Regole non negoziabili

1. **Solo SwiftUI, iOS 17+, strict concurrency.** Niente UIKit salvo wrapper strettamente necessari, niente `ObservableObject` (usa `@Observable`), niente `DispatchQueue` (usa `async/await`, `Task`, actor).
2. **Nessuna dipendenza esterna senza giustificazione scritta in `specificheTecniche.md`.** MapKit per le mappe. Non proporre Alamofire, Kingfisher, Realm, Firebase o simili.
3. **Il contratto JSON è di proprietà di `fuel-data`.** Non modificare i modelli `Codable` per "aggiustare" un campo: se il contratto non basta, scrivi una nota in `TODO.md` sezione "Richieste a fuel-data" e lavora con ciò che c'è.
4. **Zero segreti nel repo.** Team ID, bundle id personale e qualunque chiave vanno in `Config/Local.xcconfig` (ignorato da git). Se trovi un segreto committato, fermati e segnalalo.
5. **Attribuzione MIMIT obbligatoria** (licenza IODL 2.0). La schermata Info deve sempre riportare "Fonte dati: MIMIT – Osservaprezzi Carburanti" con link. Non rimuoverla, non abbreviarla.
6. **Niente stringhe hardcoded nelle View:** tutto in `Localizable.xcstrings`, italiano base + inglese.
7. **Progetto generato con XcodeGen.** Modifica `project.yml`, mai `.xcodeproj` a mano (è in `.gitignore`).
8. **Nessuna chiamata di rete fuori da `Data/Remote`.** Le View parlano solo con i ViewModel, i ViewModel solo con il repository.

## Workflow

- Prima di scrivere codice su una feature, leggi la sezione corrispondente di `specificheTecniche.md` e verifica che la voce in `TODO.md` non sia già completata o bloccata.
- Lavora a passi piccoli e buildabili. Dopo ogni modifica sostanziale esegui:
  ```
  xcodegen generate
  xcodebuild build -scheme Fuel -destination 'platform=iOS Simulator,name=iPhone 17' -quiet
  xcodebuild test  -scheme Fuel -destination 'platform=iOS Simulator,name=iPhone 17' -quiet
  swiftlint --strict
  ```
  Non dichiarare una task completata se build o test falliscono.
- Ogni nuovo tipo in `Domain/` o `Data/` nasce con il suo test. Le fixture JSON stanno in `FuelTests/Fixtures/` e devono rispettare lo schema v1; non inventare campi.
- Commit piccoli, messaggi in inglese, formato `type(scope): subject` (es. `feat(map): cluster annotations by zoom level`). **Non aggiungere trailer `Co-Authored-By` né riferimenti a Claude nei commit, nei commenti o nel codice.**
- Non creare branch o aprire PR senza che venga chiesto esplicitamente.

## Stile Swift

- 4 spazi, `swiftformat`/`swiftlint` con configurazione del repo.
- `struct` per modelli e View, `final class` solo per ViewModel e servizi con stato.
- Preferisci `enum` con `case` associati a stringhe magiche. `FuelType` è un enum `String, Codable, CaseIterable`.
- Errori tipizzati (`enum DataError: Error`) con messaggi localizzati per l'utente.
- Nomi in inglese nel codice, commenti solo dove il *perché* non è ovvio.
- Preview SwiftUI per ogni View con dati di esempio da `PreviewData`.

## Cosa NON fare

- Non scaricare i CSV del MIMIT dal client: il client legge solo `stations.json`.
- Non implementare login, account, sincronizzazione cloud, notifiche push o analytics: sono fuori scope e vanno discussi in issue prima.
- Non ottimizzare prematuramente (es. database SQLite, Core Data) finché il JSON in memoria + cache su file non si dimostra insufficiente con misure reali.
- Non usare il nome "Prezzi Benzina" da nessuna parte: è un marchio registrato di terzi.
- Non scrivere codice Android o della pipeline in questo repo.

## Quando sei in dubbio

Scegli l'opzione più semplice che rispetta le regole sopra, implementala, e lascia una riga in `TODO.md` sezione "Decisioni da confermare" con l'alternativa scartata e il motivo.
