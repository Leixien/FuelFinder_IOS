import MapKit
import SwiftUI

struct HomeView: View {
    @Bindable var model: HomeViewModel

    @State private var camera: MapCameraPosition = .region(Self.italy)
    @State private var detent: PresentationDetent = Self.compact
    @Namespace private var mapScope

    /// Tall enough for the cheapest card alone: the phone-mount view.
    static let compact = PresentationDetent.height(300)
    private static let italy = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.5, longitude: 12.5),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )

    var body: some View {
        Map(position: $camera, selection: $model.selectedStationID, scope: mapScope) {
            UserAnnotation()
            ForEach(model.result?.matches ?? []) { match in
                Annotation(Formatters.displayName(of: match.station), coordinate: match.station.coordinate) {
                    StationPin(
                        match: match,
                        isBest: match.id == model.result?.cheapest?.id,
                        isSelected: match.id == model.selectedStationID
                    )
                }
                .annotationTitles(.hidden)
                .tag(match.id)
            }
        }
        .mapControls {}
        .overlay(alignment: .top) { topBar }
        .mapScope(mapScope)
        .onChange(of: searchArea) { _, area in
            if let area {
                withAnimation { camera = .region(area) }
            }
        }
        .sheet(isPresented: .constant(true)) {
            ResultsSheet(model: model)
                .presentationDetents([Self.compact, .medium, .large], selection: $detent)
                .presentationBackgroundInteraction(.enabled)
                // Opaque, not glass: the map showing through costs contrast when read from a phone mount.
                .presentationBackground(.background)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
        }
        .onChange(of: model.selectedStationID) { _, id in
            withAnimation { detent = id == nil ? Self.compact : .large }
        }
        .task { await model.start() }
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            // Scrolls instead of clipping when a long fuel name or a large text size widens the chips.
            ScrollView(.horizontal) {
                FilterChips(fuel: $model.fuel, mode: $model.mode, sort: $model.sort)
                    .padding(.vertical, 6)
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            VStack(spacing: 0) {
                MapUserLocationButton(scope: mapScope)
            }
            .buttonBorderShape(.roundedRectangle)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    /// Frames the searched circle, so widening the radius zooms out to the stations it found.
    private var searchArea: MKCoordinateRegion? {
        guard let origin = model.origin, let radius = model.result?.radius else { return nil }
        return MKCoordinateRegion(center: origin, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2)
    }
}

extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude && lhs.center.longitude == rhs.center.longitude
            && lhs.span.latitudeDelta == rhs.span.latitudeDelta && lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

private struct ResultsSheet: View {
    @Bindable var model: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let selected = model.selectedMatch {
                    StationDetailView(match: selected, fuel: model.fuel, now: model.now) {
                        model.selectedStationID = nil
                    }
                } else {
                    if let banner = model.staleBanner {
                        StaleBannerView(banner: banner)
                    }
                    content
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    @ViewBuilder private var content: some View {
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
                message: LocalizedStringKey(error.localizedDescription),
                systemImage: "exclamationmark.triangle"
            ) {
                Button("Riprova") { Task { await model.retry() } }
                    .buttonStyle(.bordered)
                    .padding(.top, 4)
            }
        case let .results(result):
            results(result)
        }
    }

    @ViewBuilder private func results(_ result: NearbyResult) -> some View {
        if result.matches.isEmpty {
            StateCard(
                title: "Nessun distributore entro \(Formatters.radius(result.radius))",
                message: "Nessun impianto vende \(Text(model.fuel.localizedName)) qui vicino. Prova un altro carburante.",
                systemImage: "fuelpump.slash"
            )
        } else {
            if let cheapest = result.cheapest {
                CheapestCard(match: cheapest, radius: result.radius, now: model.now) {
                    model.selectedStationID = cheapest.id
                }
            } else {
                StateCard(
                    title: "Nessun prezzo recente",
                    message: "Qui vicino nessun distributore ha aggiornato il prezzo negli ultimi 7 giorni.",
                    systemImage: "clock.badge.exclamationmark"
                )
            }
            stationList(result)
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

#if DEBUG
    #Preview {
        HomeView(model: HomeViewModel(environment: .uiTest()))
    }
#endif
