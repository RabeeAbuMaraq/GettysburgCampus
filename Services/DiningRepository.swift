import Foundation
import Combine

@MainActor
final class DiningRepository: ObservableObject {
    private let api = FDClient()
    @Published var periodsByLocation: [Int: [FDMealPeriod]] = [:]
    @Published var itemsByKey: [String: [FDMealItem]] = [:] // key = "\(locId)-\(periodId)-\(date)"

    func load(date: Date) async {
        do {
            // Get all meal periods per location (token not required; will auto-refresh on 401)
            for loc in FDConfig.locations {
                do {
                    let periods = try await api.mealPeriods(locationId: loc.id)
                    periodsByLocation[loc.id] = periods
                } catch {
                    print("DiningRepository: failed to load periods for loc=\(loc.id):", error)
                    periodsByLocation[loc.id] = []
                }
            }

            let ymd = Self.format(date)
            let tzMins = TimeZone.current.secondsFromGMT() / 60

            // Fetch menus in parallel
            await withTaskGroup(of: (String, [FDMealItem]).self) { group in
                for loc in FDConfig.locations {
                    guard let periods = periodsByLocation[loc.id], !periods.isEmpty else { continue }
                    for p in periods {
                        group.addTask { [api] in
                            do {
                                let items = try await api.meals(locationId: loc.id, mealPeriodId: p.id, from: ymd, to: ymd, timeOffsetMinutes: tzMins)
                                return ("\(loc.id)-\(p.id)-\(ymd)", items)
                            } catch {
                                return ("\(loc.id)-\(p.id)-\(ymd)", [])
                            }
                        }
                    }
                }
                for await (key, items) in group {
                    itemsByKey[key] = items
                }
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


