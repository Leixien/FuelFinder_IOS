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
    var selectedStationID: Station.ID?

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

    var selectedMatch: StationMatch? {
        result?.matches.first { $0.id == selectedStationID }
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
        recompute()
    }

    private func recompute() {
        staleBanner = payload
            .flatMap { DataFreshness.staleDays(pricesReferenceDate: $0.pricesReferenceDate, now: now) }
            .map { StaleBanner(days: $0, offline: refreshError == .network) }
        content = makeContent()
        // A station that left the results (new fuel, mode or position) cannot stay open in the detail.
        if selectedStationID != nil, selectedMatch == nil {
            selectedStationID = nil
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
