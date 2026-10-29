import Foundation

/// Last downloaded `stations.json`, kept as raw bytes with its ETag.
struct FileCache: Sendable {
    struct Entry: Sendable, Equatable {
        let data: Data
        let etag: String?
        let downloadedAt: Date
    }

    let directory: URL

    init(directory: URL = .applicationSupportDirectory.appending(path: "StationsCache")) {
        self.directory = directory
    }

    private var payloadURL: URL {
        directory.appending(path: "stations.json")
    }

    private var metadataURL: URL {
        directory.appending(path: "metadata.json")
    }

    func load() -> Entry? {
        guard let data = try? Data(contentsOf: payloadURL),
              let metadataData = try? Data(contentsOf: metadataURL),
              let metadata = try? JSONDecoder().decode(Metadata.self, from: metadataData)
        else { return nil }
        return Entry(data: data, etag: metadata.etag, downloadedAt: metadata.downloadedAt)
    }

    func save(_ entry: Entry) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        // Re-downloadable data must not end up in iCloud backups.
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var directory = directory
        try directory.setResourceValues(values)
        // Payload first: a crash in between leaves an old ETag, which only costs a full download.
        try entry.data.write(to: payloadURL, options: .atomic)
        try JSONEncoder().encode(Metadata(etag: entry.etag, downloadedAt: entry.downloadedAt))
            .write(to: metadataURL, options: .atomic)
    }

    private struct Metadata: Codable {
        let etag: String?
        let downloadedAt: Date
    }
}
