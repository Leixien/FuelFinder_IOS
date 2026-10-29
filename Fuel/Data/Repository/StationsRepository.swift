import Foundation

struct StationsSnapshot: Sendable {
    let payload: StationsPayload
    let downloadedAt: Date
}

/// Cache-first access to stations: callers show `cached()` right away, then call `refresh()`.
actor StationsRepository {
    private let dataSource: StationsDataSource
    private let cache: FileCache
    private var snapshot: StationsSnapshot?
    private var etag: String?

    init(dataSource: StationsDataSource, cache: FileCache) {
        self.dataSource = dataSource
        self.cache = cache
    }

    /// Last known data from memory or disk; nil on first launch or if the cache is unreadable.
    func cached() -> StationsSnapshot? {
        if let snapshot {
            return snapshot
        }
        guard let entry = cache.load(), let payload = try? StationsDecoder.decode(entry.data) else { return nil }
        etag = entry.etag
        snapshot = StationsSnapshot(payload: payload, downloadedAt: entry.downloadedAt)
        return snapshot
    }

    /// Downloads newer data if the server has any; on 304 returns the cached snapshot.
    /// ponytail: concurrent calls download twice, add an in-flight task if more than one caller appears.
    func refresh() async throws(DataError) -> StationsSnapshot {
        let current = cached()
        switch try await dataSource.fetch(etag: current == nil ? nil : etag) {
        case .notModified:
            guard let current else { throw .httpStatus(304) }
            return current
        case let .modified(data, newEtag):
            let payload = try StationsDecoder.decode(data)
            let entry = FileCache.Entry(data: data, etag: newEtag, downloadedAt: .now)
            // A failed write only costs a re-download on next launch.
            try? cache.save(entry)
            etag = newEtag
            let fresh = StationsSnapshot(payload: payload, downloadedAt: entry.downloadedAt)
            snapshot = fresh
            return fresh
        }
    }
}
