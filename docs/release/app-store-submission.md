# App Store: pubblicazione

Passi in ordine, dalla firma all'invio in revisione. Testi: `app-store-listing.md`. Privacy: `app-store-privacy.md`. Screenshot: `screenshots/`.

## 1. Account e identificativi (una volta)

- [ ] Apple Developer Program attivo (99 €/anno). Persona fisica va bene: il nome dell'account compare sotto il nome dell'app.
- [ ] developer.apple.com → Identifiers → App ID esplicito `com.leixien.refyl` (nessuna capability da attivare).
- [ ] `Config/Local.xcconfig` (gitignored) da `Local.xcconfig.example` con il proprio `DEVELOPMENT_TEAM`; il bundle id resta quello di `Shared.xcconfig`.
- [ ] App Store Connect → App → "+" Nuova app: piattaforma iOS, nome `Refyl: Prezzi Carburante`, lingua principale Italiano, bundle id `com.leixien.refyl`, SKU `refyl-ios`, accesso completo.

## 2. Build

- [ ] Versione in `project.yml`: `MARKETING_VERSION` (es. `1.0.0`) e `CURRENT_PROJECT_VERSION` (+1 a ogni upload, anche per la stessa versione).
- [ ] `xcodegen generate`, test e `swiftlint --strict` verdi.
- [ ] Xcode → destinazione "Any iOS Device (arm64)" → Product → Archive.
- [ ] Organizer → l'archivio → Generate Privacy Report: deve contenere solo il manifest di Refyl (UserDefaults `CA92.1`).
- [ ] Organizer → Distribute App → App Store Connect → Upload (firma automatica).

`ITSAppUsesNonExemptEncryption = false` è nell'Info.plist: la build non chiede la conformità all'esportazione (l'app usa solo HTTPS di sistema).

## 3. TestFlight

- [ ] Attendere l'elaborazione (10–30 min, email da Apple).
- [ ] Test interno: aggiungere il proprio Apple ID, installare da TestFlight, provare su iPhone reale (posizione negata, VoiceOver, guida con il telefono sul supporto: voce aperta in `TODO.md`).
- [ ] Test pubblico (facoltativo): gruppo esterno + link pubblico. La prima build esterna passa una revisione Beta (di solito < 1 giorno) e chiede "Beta App Description", email di feedback e la stessa privacy policy.

## 4. Scheda in App Store Connect

- [ ] Testi IT e localizzazione EN (U.S.) da `app-store-listing.md`.
- [ ] Screenshot iPhone 6,9" da `screenshots/it` e `screenshots/en` (Apple ridimensiona da soli per gli schermi più piccoli). Niente iPad: l'app è solo iPhone.
- [ ] Icona: arriva dalla build, nessun upload.
- [ ] App Privacy: risposte da `app-store-privacy.md` → "Data Not Collected".
- [ ] Classificazione per età: tutte le voci "No" / "Nessuno" → **4+**. Nessun contenuto generato da utenti, nessun web browser, nessun acquisto.
- [ ] Diritti sui contenuti: "Sì, contiene contenuti di terzi" → "Sì, ho i diritti": prezzi MIMIT con licenza IODL 2.0, che permette il riuso anche commerciale con attribuzione (presente nella schermata Info).
- [ ] Prezzo: Gratis. Disponibilità: tutti i paesi (i dati sono solo italiani, ma servono anche a chi guida in Italia con un account estero) oppure solo Italia per partire.
- [ ] Digital Services Act (UE): obbligatorio dichiarare lo stato di "trader" prima di distribuire nell'UE. Un privato con app gratuita, senza pubblicità né acquisti, di solito non è trader; se si dichiara trader, nome, indirizzo, telefono ed email diventano pubblici sulla pagina dello store. Scelta da fare in Business → Conformità.

## 5. Informazioni per la revisione

- Accesso: nessun login richiesto.
- Contatto: nome, telefono ed email del titolare (non pubblici).
- Note per il revisore:

```
Refyl shows Italian fuel prices from the official open data of the Italian Ministry of Enterprises (MIMIT – Osservaprezzi Carburanti, IODL 2.0 licence). No account, no ads, no analytics.

Location is used only on the device to find nearby stations. If you deny it, or you are outside Italy, the map opens on Italy and you can browse it by hand: every station shows its price.

The app downloads one public JSON file (https://leixien.github.io/FuelFinder_DATA/stations.json), regenerated every day from the ministry data. It also works offline with the last downloaded file.
```

## 6. Invio

- [ ] Selezionare la build nella versione, "Rilascio manuale" (per scegliere il momento) o automatico.
- [ ] Aggiungi per la revisione → Invia. Tempi tipici: 24–48 h.
- [ ] Dopo l'approvazione: rilascia, aggiorna `TODO.md` e il README con il link allo store.

## Rifiuti probabili e risposta

| Linea guida | Rischio | Risposta già pronta |
|---|---|---|
| 4.2 Funzionalità minime | basso: l'app fa una cosa sola | mappa, filtri, dettaglio, offline: non è un sito impacchettato |
| 5.1.1 Posizione | basso | testo del permesso specifico, app usabile anche senza |
| 5.2.1 Contenuti di terzi | basso | fonte e licenza nella schermata Info e nella descrizione |
