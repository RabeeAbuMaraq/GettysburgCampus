import Foundation

final class FDClient {
    private var bearer: String?
    private let decoder = JSONDecoder()

    // MARK: Token

    // The token endpoint returns a short lived JWT. Refresh on 401.
    func refreshToken() async throws {
        var req = URLRequest(url: FDConfig.tokenURL)
        req.httpMethod = "GET"
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        // Support common shapes: {"token":"..."} or {"data":{"token":"..."}}
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let token = obj["token"] as? String {
                bearer = token
                return
            }
            if let dataObj = obj["data"] as? [String: Any], let token = dataObj["token"] as? String {
                bearer = token
                return
            }
        }
        // If plain text
        if let s = String(data: data, encoding: .utf8), !s.isEmpty {
            bearer = s.trimmingCharacters(in: .whitespacesAndNewlines)
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
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let b = bearer { req.setValue("Bearer \(b)", forHTTPHeaderField: "Authorization") }
        return req
    }

    // MARK: Meal Periods

    func mealPeriods(locationId: Int) async throws -> [FDMealPeriod] {
        let path = FDConfig.apiPrefix + "/mealPeriods"
        var req = try makeRequest(path: path, query: [
            "IsActive": "1",
            "LocationId": String(locationId)
        ])

        // Call with token. If we do not have one yet, grab it first.
        if bearer == nil { try await refreshToken() }
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, http.statusCode == 401 {
                try await refreshToken()
                req = try makeRequest(path: path, query: ["IsActive":"1","LocationId": String(locationId)])
                let (data2, resp2) = try await URLSession.shared.data(for: req)
                guard (resp2 as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
                return try decoder.decode([FDMealPeriod].self, from: data2)
            }
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
            return try decoder.decode([FDMealPeriod].self, from: data)
        } catch {
            throw error
        }
    }

    // MARK: Meals

    // Example meals URL you provided:
    // /api/v1/data-locator-webapi/19/meals?menuId=0&accountId=4&locationId=4&mealPeriodId=4&tenantId=19&monthId=8&fromDate=2025/08/01&endDate=2025/08/31&timeOffset=480
    func meals(locationId: Int, mealPeriodId: Int, from ymd: String, to ymdTo: String, timeOffsetMinutes: Int) async throws -> [FDMealItem] {
        let path = FDConfig.apiPrefix + "/meals"
        var req = try makeRequest(path: path, query: [
            "menuId": "0",
            "accountId": String(FDConfig.accountId),
            "locationId": String(locationId),
            "mealPeriodId": String(mealPeriodId),
            "tenantId": String(FDConfig.tenantId),
            "fromDate": ymd,   // "yyyy/MM/dd"
            "endDate": ymdTo, // same day or range
            "timeOffset": String(timeOffsetMinutes)
        ])

        if bearer == nil { try await refreshToken() }

        func decodeItems(from data: Data) throws -> [FDMealItem] {
            // The payload shape can vary. Use a resilient extractor.
            // Strategy: traverse the JSON and pick any array of dictionaries
            // that looks like menu items with a name-like key.
            let any = try JSONSerialization.jsonObject(with: data, options: []) as? Any
            var results: [FDMealItem] = []
            func walk(_ node: Any) {
                if let arr = node as? [[String: Any]] {
                    for dict in arr {
                        // Common name keys used by FD
                        let name = (dict["name"] ?? dict["itemName"] ?? dict["productName"]) as? String
                        guard let n = name, !n.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
                        let id = (dict["id"] ?? dict["itemId"] ?? dict["productId"] ?? UUID().uuidString) as? CustomStringConvertible
                        let station = (dict["station"] ?? dict["stationName"]) as? String
                        let desc = (dict["description"] ?? dict["itemDescription"]) as? String
                        let caloriesInt: Int? = {
                            if let c = dict["calories"] as? Int { return c }
                            if let c = dict["calories"] as? String, let v = Int(c) { return v }
                            return nil
                        }()
                        let allergens = dict["allergens"] as? [String]
                        let attributes = (dict["attributes"] as? [String])
                            ?? (dict["dietaryAttributes"] as? [String])
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

        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, http.statusCode == 401 {
            try await refreshToken()
            // rebuild request to attach fresh Authorization header
            req = try makeRequest(path: path, query: [
                "menuId": "0",
                "accountId": String(FDConfig.accountId),
                "locationId": String(locationId),
                "mealPeriodId": String(mealPeriodId),
                "tenantId": String(FDConfig.tenantId),
                "fromDate": ymd,
                "endDate": ymdTo,
                "timeOffset": String(timeOffsetMinutes)
            ])
            let (data2, resp2) = try await URLSession.shared.data(for: req)
            guard (resp2 as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
            return try decodeItems(from: data2)
        }
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try decodeItems(from: data)
    }
}


