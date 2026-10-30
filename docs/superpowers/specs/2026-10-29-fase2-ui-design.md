# Fase 2 — UI MVP: design

Data: 2026-10-29. Stato: approvato e implementato.
Mockup di riferimento (throwaway, non versionati): `.superpowers/brainstorm/*/content/home-layout.html` (opzione B) e `detail.html`.

## 1. Intento

L'utente apre l'app per sapere **subito dov'è il carburante più economico vicino a lui**. Due momenti d'uso:

- **In auto, telefono sul supporto**: uno sguardo, zero o un tocco. Serve un numero grande e un pulsante "Indicazioni".
- **Prima di partire**, con calma: confronta i distributori, guarda il dettaglio.

L'anti-modello è l'app più diffusa del settore: troppa roba sullo schermo, non si capisce cosa guardare, aspetto datato. Riferimento estetico dichiarato dall'utente: il design Apple (Mappe, Borsa, Meteo).

### Obiettivi
- Il prezzo più basso nel raggio è leggibile entro un secondo dall'apertura, senza tocchi.
- Aspetto nativo iOS curato, light e dark.
- Tutte le voci della Fase 2 in `TODO.md` coperte (posizione, lista, mappa, filtri persistiti, dettaglio, Info, banner dati vecchi/offline, stati vuoti/errore, IT/EN, dark mode e Dynamic Type).

### Non-obiettivi (MVP)
- Ricerca per comune/indirizzo, "cerca in quest'area", preferiti, storico, widget, CarPlay (restano nel backlog).
- Tab bar o navigazione multi-schermata.
- Clustering delle annotazioni (reso superfluo dalla scelta in §4.2).

### Anti-obiettivi (fallimento anche se "funziona")
- Schermata affollata: più di un numero in evidenza, card decorative, foto, pubblicità.
- Dover toccare qualcosa per vedere il prezzo migliore.
- Testo poco contrastato o piccolo: si legge da un supporto in auto.

## 2. Vincoli

Valgono `CLAUDE.md` e `specificheTecniche.md`: SwiftUI puro, iOS 17+, Swift 6 strict concurrency, `@Observable`, nessuna dipendenza esterna, MapKit, stringhe in `Localizable.xcstrings` (IT base + EN), View → ViewModel → repository, attribuzione MIMIT obbligatoria e completa nella schermata Info.

Dominio e dati già pronti (Fase 1): `StationsRepository` (`cached()` + `refresh()`), `StationFilter.nearby/price`, `StationMatch`, `ServiceMode`, `FuelType`, `DataError` con messaggi localizzati.

## 3. Decisioni dell'utente

1. **Layout "mappa + foglio"** (opzione B dei mockup). La mappa è l'app; nessuna tab bar.
2. **Card "Più economico"** in cima al foglio: prezzo gigante, nome distributore, distanza, self/servito, età del dato, pulsante "Indicazioni".
3. **Chip sopra la mappa**: carburante, self/servito, ordinamento (più economici / più vicini).
4. **Dettaglio distributore** come da mockup: nome, indirizzo, distanza, tipo (stradale/autostradale), "Indicazioni", tabella carburante × self/servito con il carburante scelto evidenziato, nome commerciale dei carburanti special (`label`), età del dato. Si parte da qui, l'utente aggiungerà altro dopo averlo provato.
5. **Interruttore tema rapido** (light/dark) in un angolo: in alto a destra, impilato sopra il pulsante ⓘ, stile controlli di Apple Mappe.
6. Direzione estetica: Apple-like. Un redesign è possibile più avanti, quindi i colori stanno in un solo posto (`DesignSystem/`).

## 4. Comportamento

### 4.1 Avvio e dati
- All'avvio: `cached()` subito, poi un solo `refresh()` in background (unico chiamante, vedi nota nel repository).
- Primo avvio senza cache: indicatore di caricamento nella card; se il download fallisce, stato d'errore con il messaggio di `DataError` e "Riprova".
- Cache presente ma refresh fallito: si usano i dati in cache, nessun errore bloccante.
- Banner nel foglio sopra la card se `prices_reference_date` è più vecchia di 48 h: "Dati di N giorni fa" (+ "offline" se l'ultimo refresh è fallito per rete). Non `downloadedAt` né `generated_at`: la pipeline può ripubblicare dati vecchi con timestamp nuovi (vedi "Blocchi noti" in `TODO.md`).

### 4.2 Posizione, raggio, mappa
- Il permesso "Quando in uso" si chiede al primo avvio (la mappa è la prima schermata; aggiornare §9 di `specificheTecniche.md` che dice "quando l'utente apre mappa o lista": coincide).
- `LocationService` espone `AsyncStream<CLLocation>` come da specifiche; la lista si ricalcola quando l'utente si sposta di almeno ~200 m, non a ogni fix.
- Raggio: 5 km. **Mia scelta:** se nel raggio non c'è nessun distributore per quel carburante, si allarga automaticamente a 10 e poi 25 km; la card dice sempre il raggio usato ("entro 10 km"). Oltre 25 km: stato vuoto "Nessun distributore con <carburante> entro 25 km".
- **Superato (decisione dell'utente dopo la prova su iPhone):** la mappa mostra i distributori dell'area inquadrata, al massimo 150, prima quelli con prezzo recente e poi i più economici; card e lista restano sulla ricerca vicino all'utente. Testo originale: i pin sono gli stessi distributori della lista (nel raggio dalla posizione dell'utente), non quelli dell'area visibile. Spostare la mappa non carica altro. Con un raggio di 5–25 km i pin sono al massimo qualche centinaio: niente clustering. "Cerca in quest'area" va nel backlog. Questo chiude la voce "Cluster delle annotazioni" in "Decisioni da confermare".
- Ogni pin mostra il prezzo del carburante scelto (3 decimali). Il più economico: verde, più grande, sempre sopra gli altri.
- Pulsante "centra su di me" standard di MapKit (`MapUserLocationButton`).
- Posizione negata (`.denied`) o bloccata (`.restricted`): mappa centrata sull'Italia, la card diventa "Posizione disattivata" con pulsante "Apri Impostazioni"; i chip restano usabili.
- **Mia scelta:** la posizione approssimativa (precisione ridotta) è trattata come normale: con un raggio di 5–25 km funziona. Nessuna richiesta di precisione piena.

### 4.3 Chip filtri
- **Carburante**: menu con tutti i casi di `FuelType` con nomi leggibili localizzati. Default benzina.
- **Self/Servito**: toggle. Default self. Se un distributore non ha la modalità scelta si usa l'altra (logica già in `StationFilter.price`) e la riga/pin mostra un badge "Servito"/"Self".
- **Mia scelta:** la card "Più economico" e il pin verde considerano solo i prezzi nella modalità scelta; i distributori in fallback compaiono solo in lista e sulla mappa, col badge. Anche l'allargamento del raggio conta solo i distributori nella modalità scelta.
- **Decisione dell'utente (dopo la revisione finale):** se entro 25 km non c'è nessun prezzo recente nella modalità scelta, la ricerca riparte da 5 km accettando anche l'altra modalità, e la card mostra il badge. Senza questo, chi cerca GPL o GNL con "Self" (il default) non avrebbe mai una risposta, perché in Italia quasi non esistono self per questi carburanti.
- **Ordinamento**: "Più economici" (default) / "Più vicini". Cambia l'ordine della lista; la card resta sempre "Più economico".
- Carburante e modalità persistiti in `UserDefaults` (`@AppStorage`). Ordinamento: **mia scelta**, persistito anch'esso.
- Nota: `specificheTecniche.md` §4.2 dice "lista ordinata per distanza"; con questa decisione il default diventa per prezzo. Aggiornare le specifiche.

### 4.4 Foglio
- Sempre presente, non chiudibile, la mappa resta interattiva dietro (`presentationBackgroundInteraction`).
- Tre altezze: **bassa** (solo card, la vista per l'auto), **media** (card + inizio lista), **alta** (lista a tutto schermo).
- Card "Più economico": prezzo con `€/l` oppure `€/kg` per metano e gnl; nome = `brand` se presente, altrimenti `name`, altrimenti "Distributore" (alcuni `name` sono vuoti); sotto: indirizzo breve, distanza, self/servito, "aggiornato 3 h fa" (da `FuelPrice.updatedAt`, formato relativo).
- Parità di prezzo: vince il più vicino.
- **Decisione dell'utente:** un prezzo con `updatedAt` più vecchio di 7 giorni non può vincere la card né il pin verde (il MIMIT ripubblica l'ultimo prezzo comunicato anche se è di anni fa; la fixture ne ha uno del 2014). Resta in lista e sulla mappa, con l'età evidenziata in arancione. Anche l'allargamento del raggio conta solo i prezzi entro 7 giorni.
- Lista: riga con nome, distanza · età, prezzo a destra (cifre tabulari); il migliore in verde.
- Tocco su pin o riga: il foglio mostra il dettaglio (sale all'altezza alta), con ✕ per tornare. Il pin selezionato è evidenziato.

### 4.5 Dettaglio
Come §3.4. Indirizzo completo `address, city (province)`. Carburanti nell'ordine di `FuelType.allCases`; celle vuote "—". **Mia scelta:** una riga per coppia (carburante, `label`), perché un distributore può vendere più prodotti della stessa categoria (es. due `gasolio_special` Q8). Quando il carburante scelto è uno special, card, righe e dettaglio mostrano il `label` del prodotto che ha vinto. "Indicazioni" apre Apple Maps in modalità guida (`MKMapItem.openInMaps`).

### 4.6 Tema
- Tre stati salvati in `@AppStorage`: sistema (default), chiaro, scuro.
- Il pulsante nell'angolo mostra ☾ quando l'aspetto attuale è chiaro e ☀︎ quando è scuro; un tocco forza l'opposto.
- **Mia scelta:** nella schermata Info c'è "Usa impostazioni di sistema" per tornare al default.
- Applicato con `preferredColorScheme` alla radice.

### 4.7 Info
Foglio aperto da ⓘ: "Fonte dati: MIMIT – Osservaprezzi Carburanti" con link (testo integrale, obbligatorio), licenza IODL 2.0, licenza del codice Apache 2.0, link al repo, versione e build, data dei dati (`generated_at` / `prices_reference_date`), opzione tema di sistema.

## 5. Accessibilità e leggibilità
- Dynamic Type su tutto; il prezzo della card usa uno stile grande ma scalabile.
- Contrasto AA: il verde "migliore" su testo bianco va scurito in light (il verde di sistema chiaro con testo bianco dà 2,2:1); in dark verde di sistema con testo nero. Il grigio secondario usa i colori semantici di sistema.
- VoiceOver: ogni pin e riga ha un'etichetta del tipo "Q8, 1,729 euro al litro, a 1,2 chilometri, self".
- Prezzi con cifre tabulari e formattazione locale (virgola in italiano).

## 6. Struttura (indicativa, dalle specifiche)
`Services/LocationService`, `Features/Map` (mappa + foglio + ViewModel), `Features/Nearby` (card e lista), `Features/StationDetail`, `Features/Filters` (chip), `Features/Info`, `DesignSystem/` (colori, formattatori prezzo/distanza/età), `App/AppEnvironment`.

## 7. Test
- Unit test sui ViewModel: scelta del più economico (parità → più vicino), esclusione dei prezzi > 7 giorni dalla card, allargamento del raggio, ordinamento, fallback self/servito, stato posizione negata, banner > 48 h.
- UI smoke: avvio → card visibile → tocco riga → dettaglio → ✕. Per renderlo deterministico l'app accetta un launch argument di test che inietta la fixture `stations_sample.json` e una posizione fissa (Napoli).
- Verifica manuale: light/dark, Dynamic Type grande, VoiceOver sulla card.

## 8. Lasciato al costruttore
Nomi dei tipi, suddivisione dei ViewModel, altezze esatte del foglio, icone SF Symbols, animazioni, testi esatti delle stringhe (in IT e EN), soglia esatta di spostamento per il ricalcolo.
