import Foundation
@testable import Fuel
import Testing

struct FileCacheTests {
    private let cache = FileCache(directory: .temporaryDirectory.appending(path: UUID().uuidString))

    @Test func emptyCacheLoadsNil() {
        #expect(cache.load() == nil)
    }

    @Test func roundTripsEntry() throws {
        let entry = FileCache.Entry(data: Data("payload".utf8), etag: "\"v1\"", downloadedAt: Date(timeIntervalSince1970: 1000))

        try cache.save(entry)

        #expect(cache.load() == entry)
        let values = try cache.directory.resourceValues(forKeys: [.isExcludedFromBackupKey])
        #expect(values.isExcludedFromBackup == true)
    }

    @Test func overwritesPreviousEntry() throws {
        try cache.save(.init(data: Data("old".utf8), etag: "\"v1\"", downloadedAt: .now))
        let newer = FileCache.Entry(data: Data("new".utf8), etag: nil, downloadedAt: .now)

        try cache.save(newer)

        #expect(cache.load() == newer)
    }
}
