/// Closed set normalised by fuel-data: raw values are the contract's `fuel` strings.
enum FuelType: String, Decodable, CaseIterable, Sendable {
    case benzina
    case gasolio
    case gpl
    case metano
    case benzinaSpecial = "benzina_special"
    case gasolioSpecial = "gasolio_special"
}
