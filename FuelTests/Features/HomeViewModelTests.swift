import CoreLocation
import Foundation
@testable import Fuel
import Testing

@MainActor
struct HomeViewModelTests {
    private let cache = FileCache(directory: .temporaryDirectory.appending(path: UUID().uuidString))
    private let defaults = UserDefaults(suiteName: UUID().uuidString)! // swiftlint:disable:this force_unwrapping

    private func environment(
        location: any LocationProviding = FixedLocation(PreviewData.origin),
        transport: @escaping StationsDataSource.Transport
    ) -> AppEnvironment {
        let source = StationsDataSource(url: URL(filePath: "/stations.json"), transport: transport)
        return AppEnvironment(
            repository: StationsRepository(dataSource: source, cache: cache),
            location: location,
            now: { PreviewData.now }
        )
    }

    private func serving(_ data: Data) -> StationsDataSource.Transport {
        { _ in (data, httpResponse(200)) }
    }

    private let offline: StationsDataSource.Transport = { _ in throw URLError(.notConnectedToInternet) }

    /// Runs `start()` until `condition` holds, then stops it.
    private func run(_ model: HomeViewModel, until condition: () -> Bool) async -> Bool {
        let task = Task { await model.start() }
        defer { task.cancel() }
        return await eventually(condition)
    }

    private func isResults(_ model: HomeViewModel) -> Bool {
        if case .results = model.content {
            true
        } else {
            false
        }
    }

    @Test func showsCheapestAfterStart() async throws {
        let model = try HomeViewModel(environment: environment(transport: serving(Fixture.sample)), defaults: defaults)

        #expect(await run(model) { isResults(model) })
        guard case let .results(result) = model.content else { return }
        #expect(result.cheapest != nil)
        #expect(model.staleBanner == nil)
    }

    @Test func waitingForFirstFixIsLocatingNotDenied() async throws {
        let model = try HomeViewModel(
            environment: environment(location: StubLocation(.authorized), transport: serving(Fixture.sample)),
            defaults: defaults
        )

        #expect(await run(model) { model.content == .locating })
    }

    @Test func deniedLocation() async throws {
        let model = try HomeViewModel(
            environment: environment(location: StubLocation(.denied), transport: serving(Fixture.sample)),
            defaults: defaults
        )

        #expect(await run(model) { model.content == .locationDenied })
    }

    @Test func asksPermissionOnFirstLaunch() async throws {
        let location = StubLocation(.notDetermined)
        let model = try HomeViewModel(environment: environment(location: location, transport: serving(Fixture.sample)), defaults: defaults)

        #expect(await run(model) { location.requestedAuthorization })
    }

    @Test func rareFuelShowsEmptyThenRecovers() async {
        let stations = """
        [{ "id": 1, "name": "A", "brand": "B", "operator": "C", "type": "stradale", "address": "Via Roma 1",
           "city": "NAPOLI", "province": "NA", "lat": 40.86, "lon": 14.27,
           "prices": [{ "fuel": "benzina", "price": 1.8, "self": true, "updated_at": "2026-10-28T06:00:00Z" }] }]
        """
        let model = HomeViewModel(
            environment: environment(transport: serving(Fixture.payload(stations: stations))), defaults: defaults
        )
        model.fuel = .gnl

        #expect(await run(model) { model.content == .results(NearbyResult(radius: 25000, matches: [], cheapest: nil)) })

        model.fuel = .benzina
        guard case let .results(result) = model.content else {
            Issue.record("expected results, got \(model.content)")
            return
        }
        #expect(result.cheapest?.id == 1)
    }

    @Test func refreshFailureWithCacheIsNotAnError() async throws {
        try cache.save(.init(data: Fixture.sample, etag: "\"v1\"", downloadedAt: .now))
        let model = HomeViewModel(environment: environment(transport: offline), defaults: defaults)

        #expect(await run(model) { isResults(model) })
        try await Task.sleep(for: .milliseconds(100))
        #expect(isResults(model))
    }

    @Test func refreshFailureWithoutCacheFails() async {
        let model = HomeViewModel(environment: environment(transport: offline), defaults: defaults)

        #expect(await run(model) { model.content == .failed(.network) })
    }

    @Test func retryRecoversAndIgnoresTapsWhileInFlight() async throws {
        let sample = try Fixture.sample
        let calls = Counter()
        let transport: StationsDataSource.Transport = { _ in
            // First launch fails; the retry succeeds slowly enough for a second tap to land mid-flight.
            if await calls.next() == 1 {
                throw URLError(.notConnectedToInternet)
            }
            try await Task.sleep(for: .milliseconds(100))
            return (sample, httpResponse(200))
        }
        let model = HomeViewModel(environment: environment(transport: transport), defaults: defaults)
        let task = Task { await model.start() }
        defer { task.cancel() }
        #expect(await eventually { model.content == .failed(.network) })

        async let first: Void = model.retry()
        async let second: Void = model.retry()
        _ = await (first, second)

        #expect(isResults(model))
        #expect(await calls.value == 2)
    }

    @Test func selectionClearsWhenStationLeavesResults() async throws {
        let model = try HomeViewModel(environment: environment(transport: serving(Fixture.sample)), defaults: defaults)
        #expect(await run(model) { model.result?.cheapest != nil })
        model.selectedStationID = model.result?.cheapest?.id

        model.fuel = .gnl

        #expect(model.selectedStationID == nil)
    }

    @Test func returningToForegroundRefreshes() async throws {
        let sample = try Fixture.sample
        let calls = Counter()
        let transport: StationsDataSource.Transport = { _ in
            // Offline at launch (garage), connected when the app comes back to the foreground.
            if await calls.next() == 1 {
                throw URLError(.notConnectedToInternet)
            }
            return (sample, httpResponse(200))
        }
        let model = HomeViewModel(environment: environment(transport: transport), defaults: defaults)
        let task = Task { await model.start() }
        defer { task.cancel() }
        #expect(await eventually { model.content == .failed(.network) })

        await model.becameActive()

        #expect(isResults(model))
    }

    @Test func staleBannerFromReferenceDate() async {
        let data = Fixture.payload(pricesReferenceDate: "2026-10-20")
        let model = HomeViewModel(environment: environment(transport: serving(data)), defaults: defaults)

        #expect(await run(model) { model.staleBanner == StaleBanner(days: 8, offline: false) })
    }

    @Test func staleBannerIsOfflineWhenRefreshFails() async throws {
        try cache.save(.init(data: Fixture.payload(pricesReferenceDate: "2026-10-20"), etag: nil, downloadedAt: .now))
        let model = HomeViewModel(environment: environment(transport: offline), defaults: defaults)

        #expect(await run(model) { model.staleBanner == StaleBanner(days: 8, offline: true) })
    }

    @Test func filtersPersistAcrossInstances() throws {
        let first = try HomeViewModel(environment: environment(transport: serving(Fixture.sample)), defaults: defaults)
        first.fuel = .gasolio
        first.mode = .fullService
        first.sort = .distance

        let second = try HomeViewModel(environment: environment(transport: serving(Fixture.sample)), defaults: defaults)

        #expect(second.fuel == .gasolio)
        #expect(second.mode == .fullService)
        #expect(second.sort == .distance)
    }
}

private actor Counter {
    private(set) var value = 0

    func next() -> Int {
        value += 1
        return value
    }
}
