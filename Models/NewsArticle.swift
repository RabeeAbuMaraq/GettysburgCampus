import Foundation

struct NewsArticle: Identifiable, Codable, Equatable {
	let id: String
	let title: String
	let summary: String
	let content: String
	let publishedAt: Date
	let imageURL: String?
	let articleURL: String
	let author: String?
	let category: NewsCategory

	init(id: String,
		 title: String,
		 summary: String,
		 content: String,
		 publishedAt: Date,
		 imageURL: String?,
		 articleURL: String,
		 author: String? = nil,
		 category: NewsCategory = .general) {
		self.id = id
		self.title = title
		self.summary = summary
		self.content = content
		self.publishedAt = publishedAt
		self.imageURL = imageURL
		self.articleURL = articleURL
		self.author = author
		self.category = category
	}

	var formattedDate: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter.string(from: publishedAt)
	}

	var timeAgo: String {
		let interval = Date().timeIntervalSince(publishedAt)
		let days = Int(interval / 86400)
		let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
		if days > 0 {
			return days == 1 ? "1 day ago" : "\(days) days ago"
		} else if hours > 0 {
			return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
		} else {
			return "Just now"
		}
	}

	var shortSummary: String {
		let maxLength = 140
		if summary.count <= maxLength { return summary }
		let truncated = String(summary.prefix(maxLength))
		return truncated + "..."
	}
}

enum NewsCategory: String, CaseIterable, Codable {
	case general = "General"
	case academic = "Academic"
	case athletics = "Athletics"
	case studentLife = "Student Life"
	case announcements = "Announcements"
	case research = "Research"

	var icon: String {
		switch self {
		case .general: return "newspaper"
		case .academic: return "graduationcap"
		case .athletics: return "sportscourt"
		case .studentLife: return "person.3"
		case .announcements: return "megaphone"
		case .research: return "magnifyingglass"
		}
	}
}


