# Brief: icona di Refyl

## Il progetto
Refyl è un'app iOS per trovare i prezzi dei carburanti dei distributori italiani. È gratuita e open source (licenza Apache 2.0, codice su GitHub). I prezzi vengono dai dati aperti ufficiali del MIMIT (Osservaprezzi Carburanti) e si aggiornano ogni giorno.

## Cosa fa
- All'apertura mostra una mappa centrata sulla posizione dell'utente, con il prezzo scritto su ogni distributore.
- Un riquadro in basso indica il distributore più economico nel raggio di 5 km (allargato a 10 o 25 km se serve), con distanza, età del prezzo e un pulsante "Indicazioni" che apre Apple Mappe.
- Filtri per carburante (benzina, gasolio, GPL, metano, GNL, HVO e versioni speciali), self o servito, ordinamento per prezzo o distanza.
- Lista dei distributori vicini e scheda di dettaglio con tutti i prezzi.
- Funziona anche offline con gli ultimi dati scaricati.

## Chi la usa e quando
Automobilisti in Italia. Due momenti d'uso:
- in auto, con il telefono sul supporto, per uno sguardo veloce;
- prima di partire, per confrontare i distributori con calma.

## Principi del progetto
- Nessuna pubblicità, nessun account, nessuna analytics.
- Nessun dato personale raccolto: la posizione resta sul telefono.
- Nessun server proprio: l'app scarica un file pubblico con i prezzi.

## Nome e store
- Nome: **Refyl**.
- Titolo sull'App Store: "Refyl: Prezzi Carburante".
- Sottotitolo: "Benzina e diesel vicino a te".
- Categoria: Navigazione.
- Lingue: italiano e inglese.

## Aspetto dell'app
- Stile nativo Apple. Da iOS 26 usa Liquid Glass (filtri, pulsanti e pannello in vetro); sulle versioni precedenti usa materiali sfocati.
- Tema chiaro e scuro, con interruttore nell'app.
- Colori usati nell'interfaccia:

| Uso | Tema chiaro | Tema scuro |
|---|---|---|
| Distributore più economico, pulsante "Indicazioni" | `#248A3D` | `#30D158` |
| Testo sopra quel colore | `#FFFFFF` | `#000000` |
| Prezzo non aggiornato da più di 7 giorni | `#C93400` | `#FF9F0A` |

## Requisiti tecnici dell'icona
- Master 1024 × 1024 px, quadrato pieno, senza angoli arrotondati né trasparenza: la maschera la applica iOS.
- Deve restare riconoscibile fino a 29 px, la dimensione mostrata nelle Impostazioni.
- Tre aspetti, richiesti da iOS 18 in poi:
  - chiaro;
  - scuro (simbolo su sfondo scuro o trasparente);
  - tinto (simbolo in scala di grigi, colorato da iOS con la tinta scelta dall'utente).
- Liquid Glass (iOS 26): l'icona va fornita a livelli separati (sfondo, simbolo, eventuale dettaglio) da assemblare con Icon Composer di Apple, che genera il file `.icon` e aggiunge riflessi e profondità. I livelli vanno consegnati con forme piatte, senza ombre o riflessi già disegnati.
- L'app supporta iOS 17 e successivi: per le versioni senza Liquid Glass si usa il PNG 1024 × 1024.

## Cosa consegnare
1. Il file `.icon` di Icon Composer, **oppure** i livelli separati in SVG o PNG 1024 × 1024.
2. Il PNG 1024 × 1024 dell'aspetto chiaro.
3. Facoltativo: aspetto scuro e tinto, se preparati a parte (altrimenti si ricavano dai livelli).

L'integrazione nell'app (asset catalog, varianti, verifica su iOS 18 e 26) è a carico dello sviluppo.
