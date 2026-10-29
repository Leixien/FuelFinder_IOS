# Contribuire

Grazie per l'interesse. Qualche regola per tenere il progetto semplice.

## Prima di iniziare

- Leggi [infoProgetto.md](infoProgetto.md), [specificheTecniche.md](specificheTecniche.md) e [TODO.md](TODO.md).
- Per modifiche non banali apri prima una issue: evita lavoro buttato.
- Login, account, sync cloud, notifiche push e analytics sono fuori scope.

## Regole

- SwiftUI, iOS 17+, strict concurrency. Niente dipendenze esterne senza motivazione scritta in `specificheTecniche.md`.
- Il progetto Xcode si genera con `xcodegen generate`: modifica `project.yml`, mai il `.xcodeproj`.
- Nessuna stringa hardcoded nelle View: usa `Localizable.xcstrings` (italiano + inglese).
- Nessun segreto nel repo: team id e bundle id personali vanno in `Config/Local.xcconfig`.
- Il contratto JSON (`stations.json`) appartiene a `fuel-data`: non adattarlo lato client.
- Ogni nuovo tipo in `Domain/` o `Data/` arriva con i suoi test.

## Workflow

1. Fork e branch dal `main`.
2. `xcodegen generate`, build, `xcodebuild test`, `swiftlint --strict`: tutto verde.
3. Commit piccoli in inglese, formato `type(scope): subject` (es. `feat(map): cluster annotations by zoom level`).
4. Apri la PR compilando il template.

Partecipando accetti il [Codice di condotta](CODE_OF_CONDUCT.md).
