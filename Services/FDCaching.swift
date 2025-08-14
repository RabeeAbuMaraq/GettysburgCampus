import Foundation

enum FDCaching {
    private static var baseDirectory: URL = {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = caches.appendingPathComponent("FDMealPlannerCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    static func mealPeriodsURL(locationId: Int) -> URL {
        let dir = baseDirectory.appendingPathComponent("mealPeriods", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("loc_\(locationId).json")
    }

    static func mealsURL(locationId: Int, mealPeriodId: Int, monthKey: String) -> URL {
        let dir = baseDirectory.appendingPathComponent("meals", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("loc_\(locationId)_period_\(mealPeriodId)_month_\(monthKey).json")
    }

    static func loadIfFresh(from url: URL, maxAgeSeconds: TimeInterval) -> Data? {
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else { return nil }
        guard let attrs = try? fm.attributesOfItem(atPath: url.path),
              let modDate = attrs[.modificationDate] as? Date else { return nil }
        if Date().timeIntervalSince(modDate) <= maxAgeSeconds {
            return try? Data(contentsOf: url)
        }
        return nil
    }

    static func save(_ data: Data, to url: URL) {
        do {
            try data.write(to: url, options: [.atomic])
        } catch {
            // ignore cache write failures
        }
    }
}


