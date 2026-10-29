import Foundation

/// Root of `stations.json` (contract owned by fuel-data).
struct StationsPayload: Decodable, Sendable {
    static let supportedSchemaVersion = 1

    let schemaVersion: Int
    let generatedAt: Date
    /// `yyyy-MM-dd`, the day the MIMIT prices refer to.
    let pricesReferenceDate: String
    let source: Source
    let stations: [Station]

    struct Source: Decodable, Sendable, Equatable {
        let name: String
        let license: String
        let url: URL
    }
}
