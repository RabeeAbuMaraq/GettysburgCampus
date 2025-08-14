import Foundation
import Combine

final class NewsService: ObservableObject {
	static let shared = NewsService()

	@Published var articles: [NewsArticle] = []
	@Published var isLoading = false
	@Published var errorMessage: String?
	@Published var lastUpdated: Date?

	private let rssURL = URL(string: "https://feeds.feedburner.com/GettysburgCollege")!
	private var cancellables = Set<AnyCancellable>()

	init() {
		load()
	}

	func load() {
		isLoading = true
		errorMessage = nil

		URLSession.shared.dataTaskPublisher(for: rssURL)
			.map { $0.data }
			.tryMap { data in try Self.parseRSS(data: data) }
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
				guard let self = self else { return }
				self.isLoading = false
				if case .failure(let error) = completion {
					self.errorMessage = error.localizedDescription
				}
			}, receiveValue: { [weak self] articles in
				guard let self = self else { return }
				self.lastUpdated = Date()
				self.articles = articles.sorted { $0.publishedAt > $1.publishedAt }
			})
			.store(in: &cancellables)
	}

	func refresh() { load() }

	// MARK: - Parsing
	private static func parseRSS(data: Data) throws -> [NewsArticle] {
		guard let xml = String(data: data, encoding: .utf8) else { return [] }
		let items = extractItems(xml: xml)
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"

		return items.compactMap { dict in
			guard let title = dict["title"], let link = dict["link"], let pub = dict["pubDate"], let desc = dict["description"], let date = formatter.date(from: pub) else { return nil }
			let clean = cleanHTML(desc)
			let image = extractImageURL(fromHTML: desc)
			let category = inferCategory(from: title + " " + clean)
			return NewsArticle(
				id: "\(title.hashValue)_\(date.timeIntervalSince1970)",
				title: title,
				summary: clean,
				content: clean,
				publishedAt: date,
				imageURL: image,
				articleURL: link,
				author: nil,
				category: category
			)
		}
	}

	private static func extractItems(xml: String) -> [[String: String]] {
		var out: [[String: String]] = []
		let parts = xml.components(separatedBy: "<item>")
		for part in parts.dropFirst() {
			guard let end = part.range(of: "</item>")?.lowerBound else { continue }
			let content = String(part[..<end])
			var dict: [String: String] = [:]
			dict["title"] = match(content, pattern: "<title>[\\s\\S]*?</title>")
				.map { $0.replacingOccurrences(of: "<title>", with: "").replacingOccurrences(of: "</title>", with: "") }
			dict["link"] = match(content, pattern: "<link>[\\s\\S]*?</link>")
				.map { $0.replacingOccurrences(of: "<link>", with: "").replacingOccurrences(of: "</link>", with: "") }
			dict["pubDate"] = match(content, pattern: "<pubDate>[\\s\\S]*?</pubDate>")
				.map { $0.replacingOccurrences(of: "<pubDate>", with: "").replacingOccurrences(of: "</pubDate>", with: "") }
			dict["description"] = match(content, pattern: "<description[\\s\\S]*?>[\\s\\S]*?</description>")
				.map {
					$0.replacingOccurrences(of: "<description[\\s\\S]*?>", with: "", options: .regularExpression)
						.replacingOccurrences(of: "</description>", with: "")
				}
			if !dict.isEmpty { out.append(dict) }
		}
		return out
	}

	private static func match(_ text: String, pattern: String) -> String? {
		guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
		return String(text[range])
	}

	private static func cleanHTML(_ html: String) -> String {
		return html
			.replacingOccurrences(of: "<!\\[CDATA\\[", with: "", options: .regularExpression)
			.replacingOccurrences(of: "\\]\\]>", with: "", options: .regularExpression)
			.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
			.replacingOccurrences(of: "&nbsp;", with: " ")
			.replacingOccurrences(of: "&amp;", with: "&")
			.replacingOccurrences(of: "&lt;", with: "<")
			.replacingOccurrences(of: "&gt;", with: ">")
			.replacingOccurrences(of: "&quot;", with: "\"")
			.replacingOccurrences(of: "&rsquo;", with: "'")
			.replacingOccurrences(of: "&ldquo;", with: "\"")
			.replacingOccurrences(of: "&rdquo;", with: "\"")
			.replacingOccurrences(of: "&ndash;", with: "-")
			.replacingOccurrences(of: "&mdash;", with: "-")
			.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private static func extractImageURL(fromHTML html: String) -> String? {
		let pattern = "<img[^>]+src=\"([^\"]+)\""
		let regex = try? NSRegularExpression(pattern: pattern, options: [])
		let ns = html as NSString
		guard let match = regex?.firstMatch(in: html, options: [], range: NSRange(location: 0, length: ns.length)), match.numberOfRanges > 1 else { return nil }
		var url = ns.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
		if url.hasPrefix("/") { url = "https://www.gettysburg.edu" + url }
		return url
	}

	private static func inferCategory(from text: String) -> NewsCategory {
		let t = text.lowercased()
		if t.contains("athletic") || t.contains("sport") || t.contains("coach") || t.contains("team") { return .athletics }
		if t.contains("research") || t.contains("study") || t.contains("faculty") || t.contains("professor") { return .research }
		if t.contains("academic") || t.contains("program") || t.contains("degree") || t.contains("course") { return .academic }
		if t.contains("student") || t.contains("campus life") || t.contains("experience") { return .studentLife }
		if t.contains("announcement") || t.contains("update") || t.contains("news") { return .announcements }
		return .general
	}
}
