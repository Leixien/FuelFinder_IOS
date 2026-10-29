import Foundation
@testable import Fuel
import Testing

struct StationsRepositoryTests {
    private let url = URL(string: "https://example.com/stations.json")!
    private let cache = FileCache(directory: .temporaryDirectory.appending(path: UUID().uuidString))

    private func repository(_ transport: @escaping StationsDataSource.Transport) -> StationsRepository {
        StationsRepository(dataSource: StationsDataSource(url: url, transport: transport), cache: cache)
    }

    @Test func firstLaunchHasNoCache() async {
        #expect(await repository { _ in throw URLError(.notConnectedToInternet) }.cached() == nil)
    }

    @Test func refreshDownloadsAndPersists() async throws {
        let sample = try Fixture.sample
        let snapshot = try await repository { _ in (sample, httpResponse(200, etag: "\"v1\"")) }.refresh()

        #expect(snapshot.payload.stations.count == 30)
        #expect(cache.load()?.etag == "\"v1\"")
    }

    @Test func nextLaunchServesCacheAndRevalidatesWithETag() async throws {
        let sample = try Fixture.sample
        try cache.save(.init(data: sample, etag: "\"v1\"", downloadedAt: Date(timeIntervalSince1970: 1000)))
        let repository = repository { request in
            #expect(request.value(forHTTPHeaderField: "If-None-Match") == "\"v1\"")
            return (Data(), httpResponse(304))
        }

        let cached = try #require(await repository.cached())
        let refreshed = try await repository.refresh()

        #expect(cached.payload.stations.count == 30)
        #expect(refreshed.downloadedAt == cached.downloadedAt)
    }

    @Test func unreadableCacheIsIgnored() async throws {
        try cache.save(.init(data: Data("corrupt".utf8), etag: "\"v1\"", downloadedAt: .now))
        let repository = repository { request in
            #expect(request.value(forHTTPHeaderField: "If-None-Match") == nil)
            return try (Fixture.sample, httpResponse(200))
        }

        #expect(await repository.cached() == nil)
        #expect(try await repository.refresh().payload.stations.count == 30)
    }

    @Test func unsupportedSchemaKeepsPreviousData() async throws {
        let sample = try Fixture.sample
        try cache.save(.init(data: sample, etag: "\"v1\"", downloadedAt: .now))
        let repository = repository { _ in (Fixture.payload(schemaVersion: 2), httpResponse(200, etag: "\"v2\"")) }

        await #expect(throws: DataError.unsupportedSchema(2)) { try await repository.refresh() }

        #expect(cache.load()?.etag == "\"v1\"")
        #expect(await repository.cached()?.payload.stations.count == 30)
    }

    @Test func offlineKeepsCachedData() async throws {
        try cache.save(.init(data: Fixture.sample, etag: nil, downloadedAt: .now))
        let repository = repository { _ in throw URLError(.notConnectedToInternet) }

        await #expect(throws: DataError.network) { try await repository.refresh() }
        #expect(await repository.cached() != nil)
    }
}
