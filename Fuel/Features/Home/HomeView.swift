import MapKit
import SwiftUI

struct HomeView: View {
    @Bindable var model: HomeViewModel

    @State private var camera: MapCameraPosition = .region(Self.italy)
    /// Height of the banner plus the cheapest card, measured: the phone-mount view must never cut "Indicazioni".
    @State private var compactHeight: CGFloat = 300
    @State private var detent: PresentationDetent = .height(300)
    @State private var showInfo = false
    @State private var showSheet = true
    @State private var themeWhenInfoOpened: AppTheme = .system
    @AppStorage(AppTheme.storageKey) private var theme: AppTheme = .system
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @Namespace private var mapScope

    private static let italy = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.5, longitude: 12.5),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )

    private var compact: PresentationDetent {
        .height(compactHeight)
    }

    var body: some View {
        map
            .mapControls {}
            // Frames the search in the part of the map the sheet leaves visible.
            .safeAreaPadding(.bottom, compactHeight)
            .overlay(alignment: .top) { topBar }
            .mapScope(mapScope)
            // Pins follow what is on screen once the user stops moving the map.
            .onMapCameraChange(frequency: .onEnd) { context in
                let region = context.region
                model.visibleArea = MapArea(
                    center: region.center, latitudeDelta: region.span.latitudeDelta, longitudeDelta: region.span.longitudeDelta
                )
            }
            .onChange(of: searchKey) {
                // Never yank the map away from someone who panned it; the location button recentres.
                guard !camera.positionedByUser, let area = searchArea else { return }
                withAnimation { camera = .region(area) }
            }
            .sheet(isPresented: $showSheet) {
                ResultsSheet(model: model, compactHeight: $compactHeight)
                    // Presented from inside the results sheet: a view can present only one sheet at a time.
                    .sheet(isPresented: $showInfo, onDismiss: resetSheetIfNeeded) { InfoView(payload: model.payload) }
                    .presentationDetents([compact, .medium, .large], selection: $detent)
                    .presentationBackgroundInteraction(.enabled)
                    // System sheet: Liquid Glass at the compact height on iOS 26, opaque when raised and on earlier
                    // versions. The card's text sits on it directly, so its contrast is checked in both themes.
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
            }
            .onChange(of: showInfo) { _, isShown in
                if isShown {
                    themeWhenInfoOpened = theme
                }
            }
            .onChange(of: compactHeight) { old, new in
                if detent == .height(old) {
                    detent = .height(new)
                }
            }
            .onChange(of: model.selectedStationID) { _, id in
                withAnimation { detent = id == nil ? compact : .large }
            }
            .task { await model.start() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task { await model.becameActive() }
                }
            }
    }

    /// ponytail: preferredColorScheme(nil) does not reach an already presented sheet, so going back to the system
    /// theme (only possible from Info) re-presents it once Info has closed; drop this if SwiftUI fixes the propagation.
    private func resetSheetIfNeeded() {
        guard themeWhenInfoOpened != .system, theme == .system else { return }
        showSheet = false
        Task { showSheet = true }
    }

    private var map: some View {
        Map(position: $camera, selection: $model.selectedStationID, scope: mapScope) {
            UserAnnotation()
            ForEach(otherMatches) { match in
                pin(match, isBest: false)
            }
            // Declared last so it draws above overlapping pins in dense areas.
            if let cheapest = model.result?.cheapest {
                pin(cheapest, isBest: true)
            }
        }
    }

    /// Stations in the visible area (or the nearby list before the map reports one), minus the cheapest,
    /// which is drawn last so it stays on top.
    private var otherMatches: [StationMatch] {
        let cheapestID = model.result?.cheapest?.id
        let shown = model.mapMatches.isEmpty ? (model.result?.matches ?? []) : model.mapMatches
        return shown.filter { $0.id != cheapestID }
    }

    private func pin(_ match: StationMatch, isBest: Bool) -> some MapContent {
        Annotation(Formatters.displayName(of: match.station), coordinate: match.station.coordinate) {
            StationPin(match: match, isBest: isBest, isSelected: match.id == model.selectedStationID)
        }
        .annotationTitles(.hidden)
        .tag(match.id)
    }

    private var topBar: some View {
        HStack(alignment: .top, spacing: 10) {
            // Scrolls instead of clipping when a long fuel name or a large text size widens the chips.
            ScrollView(.horizontal) {
                FilterChips(fuel: $model.fuel, mode: $model.mode, sort: $model.sort)
                    // Room for the chip shadows inside the clipped scroll area.
                    .padding(6)
            }
            .scrollIndicators(.hidden)
            // Gives back the shadow room on the outer edges only, so the chips stop short of the corner buttons.
            .padding([.leading, .vertical], -6)
            VStack(spacing: 8) {
                VStack(spacing: 0) {
                    controlButton(colorScheme == .dark ? "sun.max.fill" : "moon.fill") {
                        theme = AppTheme.toggled(from: colorScheme)
                    }
                    .accessibilityLabel(Text(colorScheme == .dark ? "Passa al tema chiaro" : "Passa al tema scuro"))
                    .accessibilityIdentifier("home.themeToggle")
                    Divider().frame(width: 44)
                    controlButton("info.circle") { showInfo = true }
                        .accessibilityLabel(Text("Informazioni"))
                        .accessibilityIdentifier("home.info")
                }
                .glassSurface(in: RoundedRectangle(cornerRadius: 12), interactive: true)
                MapUserLocationButton(scope: mapScope)
                MapCompass(scope: mapScope)
            }
            .buttonBorderShape(.roundedRectangle)
            // The 44 pt buttons keep a fixed frame: past this size the glyphs would spill out of it.
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func controlButton(_ systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// What the camera follows: a new position or a widened radius.
    private var searchKey: [Double] {
        [model.origin?.latitude ?? 0, model.origin?.longitude ?? 0, model.result?.radius ?? 0]
    }

    /// The searched circle, so widening the radius zooms out to the stations it found.
    private var searchArea: MKCoordinateRegion? {
        guard let origin = model.origin, let radius = model.result?.radius else { return nil }
        return MKCoordinateRegion(center: origin, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2)
    }
}

private struct ResultsSheet: View {
    @Bindable var model: HomeViewModel
    @Binding var compactHeight: CGFloat

    private static let topPadding: CGFloat = 24

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let selected = model.selectedMatch {
                    StationDetailView(match: selected, fuel: model.fuel, now: model.now) {
                        model.selectedStationID = nil
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        if let banner = model.staleBanner {
                            StaleBannerView(banner: banner)
                        }
                        headline
                    }
                    .onHeightChange { compactHeight = $0 + Self.topPadding + 20 }
                    if let result = model.result, !result.matches.isEmpty {
                        stationList(result)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, Self.topPadding)
            .padding(.bottom, 32)
            // Opening or closing a detail starts from the top, not where the list was scrolled.
            .id(model.selectedStationID)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    @ViewBuilder private var headline: some View {
        switch model.content {
        case .loading:
            LoadingCard(title: "Carico i prezzi…")
        case .locating:
            LoadingCard(title: "Cerco la tua posizione…")
        case .locationDenied:
            LocationDeniedCard()
        case let .failed(error):
            StateCard(
                title: "Prezzi non disponibili",
                message: Text(error.localizedDescription),
                systemImage: "exclamationmark.triangle"
            ) {
                Button("Riprova") { Task { await model.retry() } }
                    .buttonStyle(.bordered)
                    .padding(.top, 4)
            }
        case let .results(result):
            if result.matches.isEmpty {
                StateCard(
                    title: "Nessun distributore entro \(Formatters.radius(result.radius))",
                    message: Text("Nessun impianto vende \(Text(model.fuel.localizedName)) qui vicino. Prova un altro carburante."),
                    systemImage: "fuelpump.slash"
                )
            } else if let cheapest = result.cheapest {
                CheapestCard(match: cheapest, radius: result.radius, now: model.now) {
                    model.selectedStationID = cheapest.id
                }
            } else {
                StateCard(
                    title: "Nessun prezzo recente",
                    message: Text("Qui vicino nessun distributore ha aggiornato il prezzo negli ultimi 7 giorni."),
                    systemImage: "clock.badge.exclamationmark"
                )
            }
        }
    }

    private func stationList(_ result: NearbyResult) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(model.sort == .price ? "Più economici qui vicino" : "Più vicini a te")
                .font(.footnote.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .padding(.bottom, 6)
            ForEach(result.matches) { match in
                Button {
                    model.selectedStationID = match.id
                } label: {
                    StationRow(match: match, mode: model.mode, isBest: match.id == result.cheapest?.id, now: model.now)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.row.\(match.id)")
                Divider()
            }
        }
    }
}

private extension View {
    /// `onGeometryChange` is iOS 18+; this is the iOS 17 way to follow a view's height.
    func onHeightChange(_ action: @escaping (CGFloat) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { action(proxy.size.height) }
                    .onChange(of: proxy.size.height) { _, height in action(height) }
            }
        }
    }
}

#if DEBUG
    #Preview {
        HomeView(model: HomeViewModel(environment: .uiTest()))
    }
#endif
