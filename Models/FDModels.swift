import Foundation

struct FDLocation: Identifiable, Hashable, Codable {
    let id: Int
    let name: String
}

// Meal periods vary by location and the API field names are not guaranteed.
// Support both "id"/"mealPeriodId" and "name"/"mealPeriodName".
struct FDMealPeriod: Identifiable, Hashable, Codable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case mealPeriodId, mealPeriodName
    }

    init(id: Int, name: String) { self.id = id; self.name = name }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let id = try c.decodeIfPresent(Int.self, forKey: .id)
            ?? c.decode(Int.self, forKey: .mealPeriodId)
        let name = try c.decodeIfPresent(String.self, forKey: .name)
            ?? c.decode(String.self, forKey: .mealPeriodName)
        self.init(id: id, name: name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
}

// Items often have a lot of fields.
// Start with common ones and extend once we see real payloads.
struct FDMealItem: Identifiable, Hashable {
    let id: String
    let name: String
    let station: String?
    let description: String?
    let calories: Int?
    let allergens: [String]?
    let attributes: [String]?
}


