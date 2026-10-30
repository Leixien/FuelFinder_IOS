# App Store Connect: privacy

Risposte da dare in App Store Connect → App Privacy. Coerenti con `Fuel/Resources/PrivacyInfo.xcprivacy` e `PRIVACY.md`: se una delle tre cambia, vanno aggiornate tutte.

## Privacy Policy URL

`https://github.com/Leixien/FuelFinder_IOS/blob/main/PRIVACY.md`

## Data Collection

**"Do you or your third-party partners collect data from this app?" → No.**

Risultato sulla pagina dello store: **Data Not Collected / Nessun dato raccolto**.

Perché "No" è corretto per le definizioni di Apple ("collect" = trasmettere dati fuori dal dispositivo in modo da poterli conservare oltre il tempo della richiesta):

| Dato | Uso | Lascia il telefono? |
|------|-----|---------------------|
| Posizione precisa o approssimativa | ricerca dei distributori vicini, calcolata sul telefono | No |
| Preferenze (carburante, modalità, ordine, tema) | `UserDefaults` | No |
| Richiesta HTTP a GitHub Pages | download di `stations.json` | Solo IP/orario lato server, senza identificativi né posizione: non è raccolta da parte dell'app |

## Tracking

**No.** Nessun SDK, nessun identificatore pubblicitario, nessun dominio di tracciamento (`NSPrivacyTracking = false`).

## Required reason API (già nel manifest)

- `NSPrivacyAccessedAPICategoryUserDefaults` → `CA92.1` (dati letti e scritti dall'app stessa).

Da ricontrollare a ogni release che aggiunge dipendenze o API di sistema: l'archivio di Xcode genera il "Privacy Report" (Organizer → archivio → Generate Privacy Report).
