import Foundation
@testable import Fuel
import Testing

struct StationsDataSourceTests {
    private let url = URL(string: "https://example.com/stations.json")!

    @Test func sendsETagAndBypassesURLCache() async throws {
        let source = StationsDataSource(url: url) { request in
            #expect(request.value(forHTTPHeaderField: "If-None-Match") == "\"v1\"")
            #expect(request.cachePolicy == .reloadIgnoringLocalCacheData)
            return (Data(), httpResponse(304))
        }

        #expect(try await source.fetch(etag: "\"v1\"") == .notModified)
    }

    @Test func omitsETagWhenUnknown() async throws {
        let source = StationsDataSource(url: url) { request in
            #expect(request.value(forHTTPHeaderField: "If-None-Match") == nil)
            return (Data("x".utf8), httpResponse(200, etag: "\"v2\""))
        }

        #expect(try await source.fetch(etag: nil) == .modified(Data("x".utf8), etag: "\"v2\""))
    }

    @Test func mapsServerErrors() async {
        let source = StationsDataSource(url: url) { _ in (Data(), httpResponse(503)) }
        await #expect(throws: DataError.httpStatus(503)) { try await source.fetch(etag: nil) }
    }

    @Test func mapsTransportErrorsToNetwork() async {
        let source = StationsDataSource(url: url) { _ in throw URLError(.notConnectedToInternet) }
        await #expect(throws: DataError.network) { try await source.fetch(etag: nil) }
    }
}
