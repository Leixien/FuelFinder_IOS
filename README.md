# Refyl (iOS)

App iOS open source per consultare i prezzi dei carburanti dei distributori italiani, basata sui dati ufficiali dell'Osservaprezzi Carburanti del MIMIT. Nessun backend, nessun account, nessuna analytics.

> Il target Xcode e le cartelle si chiamano ancora `Fuel`: è il nome di lavoro, l'app installata e lo store usano **Refyl**.

<!-- Screenshot: in arrivo -->

## Build

Requisiti: Xcode 16+ e [XcodeGen](https://github.com/yonaskolb/XcodeGen). Non serve un account Apple a pagamento per il Simulator.

```sh
brew install xcodegen swiftlint
xcodegen generate
open Fuel.xcodeproj
```

Poi scegli un simulatore iPhone e premi Run. Il file `.xcodeproj` è generato da `project.yml` e non va modificato né committato.

Per firmare con il tuo account copia `Config/Local.xcconfig.example` in `Config/Local.xcconfig` e inserisci team id e bundle id.

## Test e lint

```sh
xcodebuild test -scheme Fuel -destination 'platform=iOS Simulator,name=iPhone 17'
swiftlint --strict
```

## Documentazione

- [infoProgetto.md](infoProgetto.md): contesto e obiettivi
- [specificheTecniche.md](specificheTecniche.md): architettura e contratto dati
- [TODO.md](TODO.md): stato del lavoro
- [CONTRIBUTING.md](CONTRIBUTING.md): come contribuire

## Fonte dati

Fonte dati: **MIMIT – Osservaprezzi Carburanti** ([dataset](https://www.mimit.gov.it/it/open-data/elenco-dataset/carburanti-prezzi-praticati-e-anagrafica-degli-impianti)), rilasciati con licenza [IODL 2.0](https://www.dati.gov.it/iodl/2.0/).

## Licenza

Codice rilasciato con licenza [Apache 2.0](LICENSE).
