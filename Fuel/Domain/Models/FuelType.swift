/// Closed set normalised by fuel-data: raw values are the contract's `fuel` strings.
enum FuelType: String, Decodable, CaseIterable, Sendable {
    case benzina
    case gasolio
    case gpl
    case metano
    /// Liquefied natural gas, per kg.
    case gnl
    /// Hydrotreated vegetable oil (renewable diesel); brand variants keep their name in `FuelPrice.label`.
    case hvo
    case benzinaSpecial = "benzina_special"
    case gasolioSpecial = "gasolio_special"
}
