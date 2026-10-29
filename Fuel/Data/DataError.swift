import Foundation

enum DataError: Error, Equatable {
    case network
    case httpStatus(Int)
    case decoding
    case unsupportedSchema(Int)
}

extension DataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .network:
            String(localized: "Connessione assente. Riprova più tardi.")
        case let .httpStatus(code):
            String(localized: "Il server dei dati non risponde (errore \(code)).")
        case .decoding:
            String(localized: "I dati ricevuti non sono validi.")
        case .unsupportedSchema:
            String(localized: "I dati sono in un formato più recente: aggiorna l'app.")
        }
    }
}
