import Foundation

struct StationsDataSource: Sendable {
    typealias Transport = @Sendable (URLRequest) async throws -> (Data, URLResponse)

    enum Response: Sendable, Equatable {
        case notModified
        case modified(Data, etag: String?)
    }

    let url: URL
    let transport: Transport

    init(url: URL, transport: @escaping Transport = { try await URLSession.shared.data(for: $0) }) {
        self.url = url
        self.transport = transport
    }

    func fetch(etag: String?) async throws(DataError) -> Response {
        var request = URLRequest(url: url)
        // Revalidation is done here with our own ETag: URLCache would turn a 304 into a cached 200.
        request.cachePolicy = .reloadIgnoringLocalCacheData
        if let etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await transport(request)
        } catch {
            throw .network
        }
        guard let http = response as? HTTPURLResponse else { throw .network }
        switch http.statusCode {
        case 304:
            return .notModified
        case 200 ..< 300:
            return .modified(data, etag: http.value(forHTTPHeaderField: "ETag"))
        default:
            throw .httpStatus(http.statusCode)
        }
    }
}
