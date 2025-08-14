import Foundation

@MainActor
final class DiningRepository: ObservableObject {
	private let api = FDClient()
	@Published var periodsByLocation: [Int: [FDMealPeriod]] = [:]
	@Published var itemsByKey: [String: [FDMealItem]] = [:] // key = "\(locId)-\(periodId)-\(date)"

	func load(date: Date) async {
		do {
			try await api.refreshToken()
			for loc in FDConfig.locations {
				periodsByLocation[loc.id] = try await api.mealPeriods(locationId: loc.id)
			}

			let ymd = Self.format(date)
			let tzMins = TimeZone.current.secondsFromGMT() / 60

			await withTaskGroup(of: (String, [FDMealItem]).self) { group in
				for loc in FDConfig.locations {
					guard let periods = periodsByLocation[loc.id], !periods.isEmpty else { continue }
					for p in periods {
						group.addTask { [api] in
							let items = try await api.meals(locationId: loc.id, mealPeriodId: p.id, from: ymd, to: ymd, timeOffsetMinutes: tzMins)
							return ("\(loc.id)-\(p.id)-\(ymd)", items)
						}
					}
				}
				for await (key, items) in group { itemsByKey[key] = items }
			}
		} catch {
			print("DiningRepository error:", error)
		}
	}

	static func format(_ d: Date) -> String {
		let f = DateFormatter()
		f.dateFormat = "yyyy/MM/dd"
		return f.string(from: d)
	}
}


