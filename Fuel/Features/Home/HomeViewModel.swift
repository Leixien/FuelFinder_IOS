import CoreLocation
import Foundation
import Observation

struct StaleBanner: Equatable {
    let days: Int
    /// The last refresh failed for lack of connection, so newer data may exist.
    let offline: Bool
}

@Observable
@MainActor
final class HomeViewModel {
    enum Content: Equatable {
        case loading
        case locating
        case locationDenied
        /// Empty `matches` is the "no station nearby" state.
        case results(NearbyResult)
        /// Only when there is no cached data to show.
        case failed(DataError)
    }

    private enum Key {
        static let fuel = "filter.fuel"
        static let mode = "filter.mode"
        static let sort = "filter.sort"
    }

    private(set) var content: Content = .loading
    private(set) var staleBanner: StaleBanner?
    private(set) var payload: StationsPayload?
    /// Last known user position; the map frames the search around it.
    private(set) var origin: CLLocationCoordinate2D?
    var selectedStationID: Station.ID? {
        didSet { selectedMatch = selectedStationID.flatMap(findMatch) }
    }

    /// Kept while the detail is open, even if the station scrolls off the map or the user drives away from it.
    private(set) var selectedMatch: StationMatch?

    /// What the map shows, which can reach well beyond the nearby search when zoomed out.
    private(set) var mapMatches: [StationMatch] = []

    var visibleArea: MapArea? {
        didSet {
            if visibleArea != oldValue {
                updateMapMatches()
            }
        }
    }

    var fuel: FuelType {
        didSet { persist(fuel.rawValue, Key.fuel) }
    }

    var mode: ServiceMode {
        didSet { persist(mode.rawValue, Key.mode) }
    }

    var sort: StationSort {
        didSet { persist(sort.rawValue, Key.sort) }
    }

    @ObservationIgnored private let environment: AppEnvironment
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var authorization: LocationAuthorization
    @ObservationIgnored private var refreshError: DataError?
    @ObservationIgnored private var isRefreshing = false

    init(environment: AppEnvironment, defaults: UserDefaults = .standard) {
        self.environment = environment
        self.defaults = defaults
        authorization = environment.location.authorization
        fuel = defaults.string(forKey: Key.fuel).flatMap(FuelType.init) ?? .benzina
        mode = defaults.string(forKey: Key.mode).flatMap(ServiceMode.init) ?? .selfService
        sort = defaults.string(forKey: Key.sort).flatMap(StationSort.init) ?? .price
    }

    var now: Date {
        environment.now()
    }

    var result: NearbyResult? {
        if case let .results(result) = content {
            result
        } else {
            nil
        }
    }

    /// Cached data first, then a refresh and location updates side by side, until the calling task is cancelled.
    func start() async {
        payload = await environment.repository.cached()?.payload
        if authorization == .notDetermined {
            environment.location.requestAuthorization()
        }
        recompute()
        await withDiscardingTaskGroup { group in
            group.addTask { await self.refresh() }
            group.addTask { await self.followLocation() }
        }
    }

    /// Shows the spinner again and ignores taps while a download is already running.
    func retry() async {
        guard !isRefreshing else { return }
        refreshError = nil
        recompute()
        await refresh()
    }

    /// iOS keeps a suspended app for days: coming back must not show yesterday's prices or a launch-time failure.
    /// The ETag makes this a cheap 304 when nothing changed.
    func becameActive() async {
        await refresh()
    }

    private func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            payload = try await environment.repository.refresh().payload
            refreshError = nil
        } catch {
            refreshError = error
        }
        recompute()
    }

    private func followLocation() async {
        for await update in environment.location.updates() {
            switch update {
            case let .authorization(value): authorization = value
            case let .location(coordinate): origin = coordinate
            }
            recompute()
        }
    }

    private func persist(_ value: String, _ key: String) {
        defaults.set(value, forKey: key)
        recompute(clearingMissingSelection: true)
    }

    private func findMatch(_ id: Station.ID) -> StationMatch? {
        result?.matches.first { $0.id == id } ?? mapMatches.first { $0.id == id }
    }

    private func updateMapMatches() {
        guard let payload, let visibleArea else {
            mapMatches = []
            return
        }
        mapMatches = StationRanking.inArea(
            payload.stations, fuel: fuel, mode: mode, area: visibleArea, origin: origin, now: now
        )
    }

    /// A new fuel or mode closes a detail whose station no longer sells it; moving or new data never does.
    private func recompute(clearingMissingSelection: Bool = false) {
        staleBanner = payload
            .flatMap { DataFreshness.staleDays(pricesReferenceDate: $0.pricesReferenceDate, now: now) }
            .map { StaleBanner(days: $0, offline: refreshError == .network) }
        content = makeContent()
        updateMapMatches()
        if let id = selectedStationID {
            if let match = findMatch(id) {
                selectedMatch = match
            } else if clearingMissingSelection {
                selectedStationID = nil
            }
        }
    }

    private func makeContent() -> Content {
        guard let payload else {
            return refreshError.map(Content.failed) ?? .loading
        }
        if authorization == .denied {
            return .locationDenied
        }
        guard let origin else { return .locating }
        return .results(StationRanking.search(
            payload.stations, fuel: fuel, mode: mode, origin: origin, sort: sort, now: now
        ))
    }
}
