import CoreLocation

struct Station: Sendable, Identifiable, Equatable {
    /// MIMIT `idImpianto`, stable across days.
    let id: Int
    let name: String
    let brand: String
    let operatorName: String
    let type: StationType
    let address: String
    let city: String
    let province: String
    let lat: Double
    let lon: Double
    let prices: [FuelPrice]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

enum StationType: String, Decodable, Sendable {
    case stradale
    case autostradale
    case altro

    init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = StationType(rawValue: raw) ?? .altro
    }
}

struct FuelPrice: Decodable, Sendable, Equatable {
    let fuel: FuelType
    /// Euro per litre, per kg for metano.
    let price: Double
    let isSelf: Bool
    let updatedAt: Date
    /// Brand name of special fuels, e.g. "Blue Diesel".
    let label: String?

    enum CodingKeys: String, CodingKey {
        case fuel, price, updatedAt, label
        case isSelf = "self"
    }
}

extension Station: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, name, brand, type, address, city, province, lat, lon, prices
        case operatorName = "operator"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        brand = try container.decode(String.self, forKey: .brand)
        operatorName = try container.decode(String.self, forKey: .operatorName)
        type = try container.decode(StationType.self, forKey: .type)
        address = try container.decode(String.self, forKey: .address)
        city = try container.decode(String.self, forKey: .city)
        province = try container.decode(String.self, forKey: .province)
        lat = try container.decode(Double.self, forKey: .lat)
        lon = try container.decode(Double.self, forKey: .lon)
        // A fuel added by fuel-data must not make the whole payload unreadable for older app versions.
        prices = try container.decode([LossyPrice].self, forKey: .prices).compactMap(\.value)
    }

    private struct LossyPrice: Decodable {
        let value: FuelPrice?

        init(from decoder: any Decoder) throws {
            value = try? FuelPrice(from: decoder)
        }
    }
}
