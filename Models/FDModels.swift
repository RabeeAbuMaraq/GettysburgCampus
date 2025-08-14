import Foundation

struct FDLocation: Identifiable, Hashable, Codable {
	let id: Int
	let name: String
}

struct FDMealPeriod: Identifiable, Hashable, Codable {
	let id: Int
	let name: String

	enum CodingKeys: String, CodingKey { case id, name, mealPeriodId, mealPeriodName }

	init(id: Int, name: String) { self.id = id; self.name = name }

	init(from decoder: Decoder) throws {
		let c = try decoder.container(keyedBy: CodingKeys.self)
		let id = try c.decodeIfPresent(Int.self, forKey: .id) ?? c.decode(Int.self, forKey: .mealPeriodId)
		let name = try c.decodeIfPresent(String.self, forKey: .name) ?? c.decode(String.self, forKey: .mealPeriodName)
		self.init(id: id, name: name)
	}
}

struct FDMealItem: Identifiable, Hashable {
	let id: String
	let name: String
	let station: String?
	let description: String?
	let calories: Int?
	let allergens: [String]?
	let attributes: [String]?
}


