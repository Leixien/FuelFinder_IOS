# Fuel — app iOS prezzi carburanti (open source)

> Nome di lavoro: **Fuel**. È un placeholder: va scelto un nome definitivo prima della pubblicazione su App Store. Non usare "Prezzi Benzina" (marchio registrato di Prezzi Benzina S.r.l.).

## Cos'è

App iOS nativa (SwiftUI) che mostra i prezzi dei carburanti praticati dai distributori italiani, con ricerca per vicinanza e filtro per tipo di carburante. I dati sono quelli ufficiali dell'**Osservaprezzi Carburanti del MIMIT** (Ministero delle Imprese e del Made in Italy): i gestori hanno l'obbligo di legge (art. 51 L. 99/2009) di comunicare i prezzi, quindi la copertura è l'intera rete nazionale, autostrade comprese, senza dipendere da segnalazioni degli utenti.

## Perché esiste

Le app esistenti (prezzibenzina.it e simili) sono prodotti commerciali chiusi, in parte basati su dati crowdsourced e in parte non più curati. L'open data del MIMIT rende possibile un'app:

- **aperta**: codice e pipeline dati pubblici, chiunque può fare fork e ricostruire tutto;
- **senza backend proprietario**: l'app legge un file JSON statico pubblicato ogni giorno, zero costi di infrastruttura e zero chiavi segrete nel repo;
- **affidabile**: fonte ufficiale, aggiornata ogni mattina.

## Ecosistema dei repository

| Repo | Ruolo |
|---|---|
| `fuel-data` | Pipeline (GitHub Action giornaliera): scarica i CSV MIMIT, li normalizza, pubblica `stations.json`. Proprietario del **contratto dati**. |
| `fuel-ios` (questo repo) | Client iOS nativo, SwiftUI. |
| `fuel-android` | Client Android nativo, Kotlin + Jetpack Compose. |

I due client sono indipendenti e condividono solo il contratto JSON (versionato con `schema_version`). Non c'è codice condiviso tra iOS e Android per scelta: la logica applicativa è piccola e tenere ogni repo buildabile con il solo IDE della piattaforma abbassa la barriera per i contributori.

## Fonte dati

- Dataset: *Carburanti – Prezzi praticati e anagrafica degli impianti* (MIMIT), aggiornamento quotidiano, dati in vigore alle ore 8 del giorno precedente alla pubblicazione.
- File: `anagrafica_impianti_attivi.csv` (impianti con coordinate) e `prezzo_alle_8.csv` (prezzi per impianto, carburante, self/servito).
- Licenza dati: **IODL 2.0** — l'attribuzione "Fonte: MIMIT – Osservaprezzi Carburanti" è obbligatoria e va mostrata in app (schermata Info) e nel README.
- Archivio storico trimestrale disponibile dal 2019 (per funzionalità future).

## Licenza del codice

Apache 2.0 (da aggiungere come `LICENSE`). Scelta rispetto a MIT per la clausola sui brevetti e perché non concede l'uso del nome del progetto ai fork.

## Maintainer

[@leixien](https://github.com/leixien). La pubblicazione su App Store resta a carico del maintainer; i contributori possono buildare ed eseguire su Simulator senza account Apple a pagamento.

## Stato

Fase 0 — bootstrap. Vedi `TODO.md`.
