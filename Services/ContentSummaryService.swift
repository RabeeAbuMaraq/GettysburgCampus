import Foundation

final class ContentSummaryService {
	static let shared = ContentSummaryService()
	private let cache = NSCache<NSString, NSString>()

	func summary(for article: NewsArticle, maxSentences: Int = 3) -> String {
		let key = "summary_\(article.id)_\(maxSentences)" as NSString
		if let cached = cache.object(forKey: key) { return cached as String }

		let base = article.content.trimmingCharacters(in: .whitespacesAndNewlines)
		if base.isEmpty { return article.summary }

		let summarized = Self.summarize(text: base, maxSentences: maxSentences)
		cache.setObject(summarized as NSString, forKey: key)
		return summarized
	}

	private static func summarize(text: String, maxSentences: Int) -> String {
		let cleaned = text.replacingOccurrences(of: "\n+", with: " ", options: .regularExpression)
		let sentences = splitIntoSentences(cleaned)
		guard sentences.count > 1 else { return cleaned }

		let stopwords = englishStopwords
		var wordFreq: [String: Int] = [:]
		for sentence in sentences {
			for token in tokenize(sentence) {
				if token.count < 3 { continue }
				if stopwords.contains(token) { continue }
				wordFreq[token, default: 0] += 1
			}
		}
		if wordFreq.isEmpty { return sentences.prefix(maxSentences).joined(separator: " ") }

		let maxFrequency = wordFreq.values.max() ?? 1
		let normalizedFreq = wordFreq.mapValues { Double($0) / Double(maxFrequency) }

		struct Scored { let index: Int; let text: String; let score: Double }
		var scored: [Scored] = []
		for (i, s) in sentences.enumerated() {
			let tokens = tokenize(s)
			if tokens.isEmpty { continue }
			let rawScore = tokens.reduce(0.0) { $0 + (normalizedFreq[$1] ?? 0.0) }
			let score = rawScore / Double(tokens.count)
			scored.append(Scored(index: i, text: s, score: score))
		}

		let top = scored.sorted { $0.score > $1.score }.prefix(maxSentences).sorted { $0.index < $1.index }
		let result = top.map { $0.text.trimmingCharacters(in: .whitespaces) }.joined(separator: " ")
		return result.isEmpty ? sentences.prefix(maxSentences).joined(separator: " ") : result
	}

	private static func splitIntoSentences(_ text: String) -> [String] {
		let parts = text.components(separatedBy: .newlines).joined(separator: " ")
		let regex = try? NSRegularExpression(pattern: "(?<=[.!?])\\s+", options: [])
		let range = NSRange(location: 0, length: (parts as NSString).length)
		var lastIndex = 0
		var sentences: [String] = []
		regex?.enumerateMatches(in: parts, options: [], range: range) { match, _, _ in
			guard let match = match else { return }
			let end = match.range.location + match.range.length
			let sentenceRange = NSRange(location: lastIndex, length: match.range.location - lastIndex)
			let sentence = (parts as NSString).substring(with: sentenceRange).trimmingCharacters(in: .whitespaces)
			if !sentence.isEmpty { sentences.append(sentence) }
			lastIndex = end
		}
		let tailRange = NSRange(location: lastIndex, length: (parts as NSString).length - lastIndex)
		let tail = (parts as NSString).substring(with: tailRange).trimmingCharacters(in: .whitespaces)
		if !tail.isEmpty { sentences.append(tail) }
		return sentences
	}

	private static func tokenize(_ text: String) -> [String] {
		return text.lowercased()
			.replacingOccurrences(of: "[^a-z0-9\\t\\s]", with: " ", options: .regularExpression)
			.split { !$0.isLetter && !$0.isNumber }
			.map { String($0) }
	}

	private static let englishStopwords: Set<String> = [
		"a","about","after","again","against","all","am","an","and","any","are","as","at","be","because","been","before","being","below","between","both","but","by","could","did","do","does","doing","down","during","each","few","for","from","further","had","has","have","having","he","her","here","hers","herself","him","himself","his","how","i","if","in","into","is","it","its","itself","just","me","more","most","my","myself","no","nor","not","now","of","off","on","once","only","or","other","our","ours","ourselves","out","over","own","same","she","should","so","some","such","than","that","the","their","theirs","them","themselves","then","there","these","they","this","those","through","to","too","under","until","up","very","was","we","were","what","when","where","which","while","who","whom","why","with","you","your","yours","yourself","yourselves"
	]
}


