import Foundation
import Combine

@MainActor
final class DiningRepository: ObservableObject {
    private let api = FDClient()

    @Published var periodsByLocation: [Int: [FDMealPeriod]] = [:]
    @Published var itemsByKey: [String: [FDMealItem]] = [:] // key = "\(locId)-\(periodId)-\(date)"

    private var lastLoadedDayKey: String?
    private var isLoading = false

    func load(date: Date) async {
        let ymd = Self.format(date)
        if isLoading && lastLoadedDayKey == ymd { return }
        isLoading = true
        defer { isLoading = false }
        if lastLoadedDayKey != ymd {
            itemsByKey = [:]
        }
        lastLoadedDayKey = ymd

        // Get all meal periods per location (token not required; will auto-refresh on 401)
        for loc in FDConfig.locations {
            do {
                let periods = try await api.mealPeriods(locationId: loc.id)
                periodsByLocation[loc.id] = periods
            } catch {
                // Handle specific error codes more gracefully
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain && nsError.code == -1017 {
                    // -1017 typically means the endpoint doesn't exist or is unavailable
                    print("DiningRepository: Location \(loc.id) appears to be unavailable (might be closed or inactive)")
                } else {
                    print("DiningRepository: Failed to load periods for location \(loc.id): \(error.localizedDescription)")
                }
                periodsByLocation[loc.id] = []
            }
        }

        let tzMins = TimeZone.current.secondsFromGMT() / 60
        // Build a monthly range around the selected date (matches web usage)
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        let startOfMonth = cal.date(from: comps) ?? date
        let endOfMonth = cal.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? date
        let rangeFrom = Self.format(startOfMonth)
        let rangeTo = Self.format(endOfMonth)

        // Fetch menus in parallel (slight stagger to avoid connection churn)
        await withTaskGroup(of: (String, [FDMealItem]).self) { group in
            for loc in FDConfig.locations {
                guard let periods = periodsByLocation[loc.id], !periods.isEmpty else { continue }
                for p in periods {
                    group.addTask { [api] in
                        try? await Task.sleep(nanoseconds: 50_000_000)
                        do {
                            let items = try await api.meals(
                                locationId: loc.id,
                                mealPeriodId: p.id,
                                selectedYMD: ymd,
                                rangeFromYMD: rangeFrom,
                                rangeToYMD: rangeTo,
                                timeOffsetMinutes: tzMins
                            )
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
    }

    static func format(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f.string(from: d)
    }
}
