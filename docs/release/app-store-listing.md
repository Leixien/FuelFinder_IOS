# App Store: scheda

Testi per App Store Connect. Lingua principale: italiano; seconda localizzazione: inglese (U.S.), per chi guida in Italia con un account straniero. Apple indicizza nome, sottotitolo e parole chiave e conta ogni parola una volta sola: non ripetere tra i tre campi.

Screenshot: `docs/release/screenshots/` (vedi il README lì).

## Italiano

| Campo | Testo | Limite |
|---|---|---|
| Nome | `Refyl: Prezzi Carburante` | 24/30 caratteri |
| Sottotitolo | `Benzina e diesel vicino a te` | 28/30 caratteri |
| Parole chiave | `distributori,gpl,metano,gasolio,self,risparmio,economica,mappa,pompa,hvo,osservaprezzi,mimit` | 92/100 byte |
| Categoria | Navigazione (secondaria: Utility) | |

### Testo promozionale (170 caratteri, modificabile senza nuova versione)

`Il distributore più economico vicino a te, al primo sguardo. Niente pubblicità, niente account, nessun dato raccolto. Prezzi ufficiali MIMIT aggiornati ogni giorno.` (163)

### Descrizione

```
Refyl ti mostra il distributore più economico vicino a te, in un colpo d'occhio.

Apri l'app: in alto vedi il prezzo più basso entro pochi chilometri, con distanza e data dell'ultimo aggiornamento. Un tocco su "Indicazioni" e Apple Mappe ti ci porta.

COSA FA
• Prezzi di benzina, gasolio, GPL, metano, GNL e HVO in tutta Italia
• Self o servito, ordinati per prezzo o per distanza
• Mappa con il prezzo su ogni distributore, il più conveniente in verde
• Scheda del distributore con tutti i prezzi, marchio, indirizzo e orario di aggiornamento
• Avviso quando un prezzo è vecchio, così non hai sorprese alla pompa
• Funziona anche senza rete con gli ultimi dati scaricati
• Tema chiaro e scuro, testo grande, VoiceOver

COSA NON FA
• Nessuna pubblicità
• Nessun account
• Nessun dato raccolto: la posizione resta sul telefono
• Nessun abbonamento

DATI UFFICIALI
I prezzi sono quelli che i gestori comunicano per legge al Ministero delle Imprese e del Made in Italy.
Fonte dati: MIMIT – Osservaprezzi Carburanti (licenza IODL 2.0).

OPEN SOURCE
Il codice è pubblico su GitHub: github.com/Leixien/FuelFinder_IOS
```

### Novità della versione 1.0

`Prima versione.`

## English (U.S.)

| Campo | Testo | Limite |
|---|---|---|
| Name | `Refyl: Italy Fuel Prices` | 24/30 |
| Subtitle | `Cheapest petrol station near` | 28/30 |
| Keywords | `gas,diesel,lpg,cng,station,cheap,map,italia,pump,petrol,benzina,gasolio,mimit` | 79/100 byte |

### Promotional text

`The cheapest fuel station near you, at a glance. No ads, no account, no data collected. Official Italian government prices, updated every day.` (144)

### Description

```
Refyl shows the cheapest fuel station near you in Italy, at a glance.

Open the app: the lowest price within a few kilometres is right at the top, with distance and how recent it is. Tap "Directions" and Apple Maps takes you there.

WHAT IT DOES
• Petrol, diesel, LPG, CNG, LNG and HVO prices across Italy
• Self-service or attended, sorted by price or distance
• Map with the price on every station, the cheapest in green
• Station page with every price, brand, address and update time
• Warns you when a price is old, so there are no surprises at the pump
• Works offline with the last data downloaded
• Light and dark theme, large text, VoiceOver

WHAT IT DOESN'T DO
• No ads
• No account
• No data collected: your location stays on the phone
• No subscription

OFFICIAL DATA
Prices are the ones station operators must report to the Italian Ministry of Enterprises and Made in Italy.
Data source: MIMIT – Osservaprezzi Carburanti (IODL 2.0 licence).

OPEN SOURCE
The code is public on GitHub: github.com/Leixien/FuelFinder_IOS
```

### What's New in 1.0

`First release.`

## Campi comuni

| Campo | Valore |
|---|---|
| Support URL | IT `https://leixien.github.io/refyl-site/supporto/`, EN `https://leixien.github.io/refyl-site/en/support/` |
| Marketing URL | IT `https://leixien.github.io/refyl-site/`, EN `https://leixien.github.io/refyl-site/en/` |
| Privacy Policy URL | IT `https://leixien.github.io/refyl-site/privacy/`, EN `https://leixien.github.io/refyl-site/en/privacy/` (sito: repo `Leixien/refyl-site`) |
| Copyright | `2026 ` + nome dell'account sviluppatore (come appare sotto il nome dell'app) |
| Prezzo | Gratis, nessun acquisto in-app |

## Perché così

- "Prezzi Carburante" nel nome: da app nuova le ricerche arrivano dalle parole chiave, non dal marchio. Tutti i concorrenti lo usano (Riserva, Il Pieno, iCarburante...).
- Il punto di forza è il contrario dei concorrenti, pieni di pubblicità: va nel testo promozionale e nella didascalia del primo screenshot, l'unico che quasi tutti guardano.
- Categoria Navigazione come il concorrente diretto "Riserva: Prezzi Carburanti".
- Inglese: "benzina" e "gasolio" nelle parole chiave perché i turisti li leggono sulle pompe.
