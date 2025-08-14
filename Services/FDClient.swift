import Foundation

final class FDClient {
    private var bearer: String?
    private let decoder = JSONDecoder()
    private let debugLoggingEnabled = true
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()

    // MARK: Token

    // The token endpoint returns a short lived JWT. Refresh on 401.
    func refreshToken() async throws {
        var req = URLRequest(url: FDConfig.tokenURL)
        req.httpMethod = "GET"
        let (data, resp) = try await session.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        if let token = extractBearerToken(from: data) {
            bearer = token
            if debugLoggingEnabled { print("FDClient: Refreshed token (len=\(token.count))") }
            return
        }
        throw URLError(.userAuthenticationRequired)
    }

    private func makeRequest(path: String, query: [String: String]) throws -> URLRequest {
        var comps = URLComponents(url: FDConfig.apiBase, resolvingAgainstBaseURL: false)!
        comps.path = path
        comps.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = comps.url else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        if let b = bearer { req.setValue("Bearer \(b)", forHTTPHeaderField: "Authorization") }
        return req
    }

    private func extractBearerToken(from data: Data) -> String? {
        // Try common JSON shapes
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let commonKeys = ["token", "access_token", "accessToken", "jwt", "jwtToken", "jwt_token"]
            for key in commonKeys {
                if let token = obj[key] as? String { return token }
            }
            if let dataObj = obj["data"] as? [String: Any] {
                for key in commonKeys {
                    if let token = dataObj[key] as? String { return token }
                }
            }
            // Deep search for any JWT-like string
            var found: String?
            func walk(_ node: Any) {
                if let s = node as? String, s.split(separator: ".").count >= 3 {
                    found = s
                    return
                }
                if let d = node as? [String: Any] { d.values.forEach { walk($0) } }
                if let a = node as? [Any] { a.forEach { walk($0) } }
            }
            walk(obj)
            if let f = found { return f }
        }
        // If plain text body
        if let s = String(data: data, encoding: .utf8) {
            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.split(separator: ".").count >= 3 { return trimmed }
            if !trimmed.isEmpty { return trimmed }
        }
        return nil
    }

    // MARK: Meal Periods

    func mealPeriods(locationId: Int) async throws -> [FDMealPeriod] {
        let path = FDConfig.apiPrefix + "/mealPeriods"
        var req = try makeRequest(path: path, query: [
            "IsActive": "1",
            "LocationId": String(locationId)
        ])

        // This endpoint appears public for Gettysburg; try without a token first.
        do {
            // Cache: 24h
            if let cached = FDCaching.loadIfFresh(from: FDCaching.mealPeriodsURL(locationId: locationId), maxAgeSeconds: 24*3600),
               let periods = try? decodeMealPeriods(from: cached) {
                if debugLoggingEnabled { print("FDClient: mealPeriods cache hit loc=\(locationId) count=\(periods.count)") }
                return periods
            }
            if debugLoggingEnabled { print("FDClient: GET \(req.url?.absoluteString ?? "")") }
            let (data, resp) = try await session.data(for: req)
            if let http = resp as? HTTPURLResponse, http.statusCode == 401 {
                try await refreshToken()
                req = try makeRequest(path: path, query: [
                    "IsActive":"1",
                    "LocationId": String(locationId)
                ])
                if debugLoggingEnabled { print("FDClient: RETRY GET \(req.url?.absoluteString ?? "") after 401") }
                let (data2, resp2) = try await session.data(for: req)
                guard (resp2 as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
                let periods = try decodeMealPeriods(from: data2)
                FDCaching.save(data2, to: FDCaching.mealPeriodsURL(locationId: locationId))
                if debugLoggingEnabled { print("FDClient: mealPeriods decoded count=\(periods.count) for loc=\(locationId)") }
                return periods
            }
            if let http = resp as? HTTPURLResponse, http.statusCode == 200 {
                let periods = try decodeMealPeriods(from: data)
                FDCaching.save(data, to: FDCaching.mealPeriodsURL(locationId: locationId))
                if debugLoggingEnabled { print("FDClient: mealPeriods decoded count=\(periods.count) for loc=\(locationId)") }
                return periods
            }
            if debugLoggingEnabled {
                let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
                let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                print("FDClient: mealPeriods failed status=\(status) url=\(req.url?.absoluteString ?? "") body=\(body.prefix(500))")
            }
            throw URLError(.badServerResponse)
        } catch {
            if debugLoggingEnabled { print("FDClient: mealPeriods network error url=\(req.url?.absoluteString ?? "") error=\(error)") }
            throw error
        }
    }

    private func decodeMealPeriods(from data: Data) throws -> [FDMealPeriod] {
        // Try plain array first
        if let arr = try? decoder.decode([FDMealPeriod].self, from: data) {
            return arr
        }
        // Flexible traversal similar to meals
        let any = try JSONSerialization.jsonObject(with: data, options: [])
        var results: [FDMealPeriod] = []
        func walk(_ node: Any) {
            if let arr = node as? [[String: Any]] {
                var batch: [FDMealPeriod] = []
                for dict in arr {
                    let id = (dict["id"] ?? dict["mealPeriodId"]) as? Int
                    let name = (dict["name"] ?? dict["mealPeriodName"]) as? String
                    if let id = id, let name = name {
                        batch.append(FDMealPeriod(id: id, name: name))
                    }
                }
                if !batch.isEmpty { results.append(contentsOf: batch) }
            }
            if let dict = node as? [String: Any] { dict.values.forEach { walk($0) } }
            if let arr = node as? [Any] { arr.forEach { walk($0) } }
        }
        walk(any)
        if !results.isEmpty { return results }
        throw URLError(.cannotParseResponse)
    }

    // MARK: Meals

    // Example meals URL you provided:
    // /api/v1/data-locator-webapi/19/meals?menuId=0&accountId=4&locationId=4&mealPeriodId=4&tenantId=19&monthId=8&fromDate=2025/08/01&endDate=2025/08/31&timeOffset=480
    func meals(locationId: Int, mealPeriodId: Int, selectedYMD: String, rangeFromYMD: String, rangeToYMD: String, timeOffsetMinutes: Int) async throws -> [FDMealItem] {
        let path = FDConfig.apiPrefix + "/meals"
        // monthId derived from the selected date (yyyy/MM/dd)
        let monthIdString: String = {
            let parts = selectedYMD.split(separator: "/")
            if parts.count >= 2, let mInt = Int(parts[1]) { return String(mInt) }
            return ""
        }()
        var query: [String: String] = [
            "menuId": "0",
            "accountId": String(FDConfig.accountId),
            "locationId": String(locationId),
            "mealPeriodId": String(mealPeriodId),
            "tenantId": String(FDConfig.tenantId),
            "fromDate": rangeFromYMD,   // "yyyy/MM/dd"
            "endDate": rangeToYMD, // range (e.g., month)
            "timeOffset": String(abs(timeOffsetMinutes))
        ]
        if !monthIdString.isEmpty { query["monthId"] = monthIdString }
        var req = try makeRequest(path: path, query: query)

        // Do not prefetch token; retry on 401 instead

        func decodeItems(from data: Data) throws -> [FDMealItem] {
            // The payload shape can vary. Use a resilient extractor.
            // Strategy: traverse the JSON and pick any array of dictionaries
            // that looks like menu items with a name-like key.
            // FD meals often returns { result: [ ... ] }
            if let root = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let result = root["result"] as? [[String: Any]] {
                // Filter by selected date if present
                let targetDateDashed = selectedYMD.replacingOccurrences(of: "/", with: "-")
                let dayObjects = result.filter { day in
                    if let d = day["strMenuForDate"] as? String { return d == targetDateDashed }
                    if let d2 = day["strMenuToDate"] as? String { return d2 == targetDateDashed }
                    return false
                }
                var collected: [FDMealItem] = []
                for day in dayObjects {
                    if let recipes = day["menuRecipiesData"] as? [[String: Any]] {
                        for r in recipes {
                            let name = (r["componentEnglishName"] ?? r["componentName"]) as? String
                            guard let n = name, !n.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
                            let idVal = (r["menuDetailId"] ?? r["componentId"]) as? CustomStringConvertible
                            let station = (r["category"] ?? r["menuTypeName"]) as? String
                            let desc = (r["componentEnglishDescription"] ?? r["componentSpanishDescription"]) as? String
                            let caloriesInt: Int? = {
                                if let c = r["calories"] as? Int { return c }
                                if let c = r["calories"] as? String, let v = Int(c.trimmingCharacters(in: .whitespaces)) { return v }
                                return nil
                            }()
                            let allergens = (r["allergenName"] as? String)?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                            let attributes = (r["dietaryName"] as? String)?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                            collected.append(FDMealItem(
                                id: String(describing: idVal ?? UUID().uuidString),
                                name: n,
                                station: station?.trimmingCharacters(in: .whitespaces),
                                description: (desc?.trimmingCharacters(in: .whitespaces)).flatMap { $0.isEmpty ? nil : $0 },
                                calories: caloriesInt,
                                allergens: (allergens?.isEmpty == true) ? nil : allergens,
                                attributes: (attributes?.isEmpty == true) ? nil : attributes
                            ))
                        }
                    }
                }
                return collected
            }
            let any = try JSONSerialization.jsonObject(with: data, options: []) as? Any
            var results: [FDMealItem] = []
            func walk(_ node: Any) {
                if let arr = node as? [[String: Any]] {
                    for dict in arr {
                        // Common name keys used by FD
                        let name = (dict["name"] ?? dict["itemName"] ?? dict["productName"] ?? dict["componentEnglishName"] ?? dict["componentName"]) as? String
                        guard let n = name, !n.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
                        let id = (dict["id"] ?? dict["itemId"] ?? dict["productId"] ?? dict["menuDetailId"] ?? dict["componentId"] ?? UUID().uuidString) as? CustomStringConvertible
                        let station = (dict["station"] ?? dict["stationName"] ?? dict["category"] ?? dict["menuTypeName"]) as? String
                        let desc = (dict["description"] ?? dict["itemDescription"] ?? dict["componentEnglishDescription"] ?? dict["componentSpanishDescription"]) as? String
                        let caloriesInt: Int? = {
                            if let c = dict["calories"] as? Int { return c }
                            if let c = dict["calories"] as? String, let v = Int(c) { return v }
                            return nil
                        }()
                        var allergens: [String]? = dict["allergens"] as? [String]
                        if allergens == nil, let a = dict["allergenName"] as? String { allergens = a.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                        var attributes: [String]? = (dict["attributes"] as? [String]) ?? (dict["dietaryAttributes"] as? [String])
                        if attributes == nil, let a = dict["dietaryName"] as? String { attributes = a.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                        let item = FDMealItem(
                            id: String(describing: id ?? UUID().uuidString),
                            name: n,
                            station: station,
                            description: desc,
                            calories: caloriesInt,
                            allergens: allergens,
                            attributes: attributes
                        )
                        results.append(item)
                    }
                }
                if let dict = node as? [String: Any] {
                    for v in dict.values { walk(v) }
                }
                if let arr = node as? [Any] {
                    for v in arr { walk(v) }
                }
            }
            walk(any as Any)
            return results
        }

        if debugLoggingEnabled { print("FDClient: GET \(req.url?.absoluteString ?? "")") }
        // Cache: per location/period/month, 6 hours
        let monthKey = selectedYMD.prefix(7).replacingOccurrences(of: "/", with: "-")
        let cacheURL = FDCaching.mealsURL(locationId: locationId, mealPeriodId: mealPeriodId, monthKey: String(monthKey))
        if let cached = FDCaching.loadIfFresh(from: cacheURL, maxAgeSeconds: 6*3600) {
            let items = try decodeItems(from: cached)
            if debugLoggingEnabled { print("FDClient: meals cache hit loc=\(locationId) period=\(mealPeriodId) count=\(items.count)") }
            return items
        }
        let (data, resp) = try await session.data(for: req)
        if let http = resp as? HTTPURLResponse, http.statusCode == 401 {
            try await refreshToken()
            // rebuild request to attach fresh Authorization header
            var retryQuery = query
            req = try makeRequest(path: path, query: retryQuery)
            if debugLoggingEnabled { print("FDClient: RETRY GET \(req.url?.absoluteString ?? "") after 401") }
            let (data2, resp2) = try await session.data(for: req)
            guard (resp2 as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
            let items = try decodeItems(from: data2)
            FDCaching.save(data2, to: cacheURL)
            return items
        }
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            if debugLoggingEnabled {
                let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
                let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                print("FDClient: meals failed status=\(status) url=\(req.url?.absoluteString ?? "") body=\(body.prefix(500))")
            }
            throw URLError(.badServerResponse)
        }
        let items = try decodeItems(from: data)
        FDCaching.save(data, to: cacheURL)
        if debugLoggingEnabled { print("FDClient: meals decoded count=\(items.count) for loc=\(locationId) period=\(mealPeriodId)") }
        return items
    }
}


