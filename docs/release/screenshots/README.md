# Screenshot App Store

iPhone 6,9" (1320×2868, RGB senza alpha), 5 per lingua, nell'ordine di caricamento: `it/` per l'italiano, `en/` per l'inglese. Apple li ridimensiona per gli schermi più piccoli.

| # | Schermata | Didascalia (IT) |
|---|---|---|
| 1 | Mappa + card più economico | Il più economico vicino a te, al primo sguardo |
| 2 | Lista espansa | Tutti i prezzi in ordine |
| 3 | Dettaglio distributore | Ogni carburante, ogni distributore |
| 4 | Menu carburanti | Benzina, gasolio, GPL, metano e altro |
| 5 | Tema scuro | Leggibile anche di notte |

Didascalie e colori stanno in `frame.py`.

## Rifarli

Dati reali, non la fixture: i prezzi cambiano a ogni cattura.

1. Simulatore **iPhone 17 Pro Max con iOS 26**. Su iOS 27 il simulatore non carica le mappe (anche in Apple Mappe).
2. Lingua di sistema: `xcrun simctl spawn <udid> defaults write -g AppleLanguages -array it` (poi `en`), `AppleLocale it_IT` / `en_US`, riavvio del simulatore.
3. `xcrun simctl privacy <udid> grant location com.leixien.refyl`, posizione Imola `xcrun simctl location <udid> set 44.3533,11.7147`: pochi distributori, mappa leggibile.
4. Barra di stato pulita: `xcrun simctl status_bar <udid> override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4`.
5. Cattura con `xcrun simctl io <udid> screenshot raw/it-1-home.png` (nomi: `{it,en}-{1-home,2-list,3-detail,4-fuels,5-dark}.png`). Il dettaglio è il Q8 di via Emilia Levante (ha anche il GPL). Per il tema scuro riaprire l'app dopo averlo attivato: il foglio già aperto resta chiaro.
6. `python3 frame.py raw .` (richiede Pillow e Google Chrome).
