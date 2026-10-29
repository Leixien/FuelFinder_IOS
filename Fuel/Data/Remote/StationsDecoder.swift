import Foundation

enum StationsDecoder {
    static func decode(_ data: Data) throws(DataError) -> StationsPayload {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        do {
            let payload = try decoder.decode(StationsPayload.self, from: data)
            guard payload.schemaVersion <= StationsPayload.supportedSchemaVersion else {
                throw DataError.unsupportedSchema(payload.schemaVersion)
            }
            return payload
        } catch let error as DataError {
            throw error
        } catch {
            // An incompatible newer schema usually fails decoding before its version can be checked.
            if let header = try? decoder.decode(Header.self, from: data),
               header.schemaVersion > StationsPayload.supportedSchemaVersion {
                throw .unsupportedSchema(header.schemaVersion)
            }
            throw .decoding
        }
    }

    private struct Header: Decodable {
        let schemaVersion: Int
    }
}
