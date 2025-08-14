import SwiftUI

struct NewsListView: View {
	@StateObject private var newsService = NewsService.shared
	@State private var searchText = ""
	@State private var selectedCategory: NewsCategory? = nil

	private var filtered: [NewsArticle] {
		var items = newsService.articles
		if let cat = selectedCategory { items = items.filter { $0.category == cat } }
		if !searchText.isEmpty {
			items = items.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.summary.localizedCaseInsensitiveContains(searchText) }
		}
		return items
	}

	var body: some View {
		ZStack {
			DesignSystem.Colors.backgroundGradient.ignoresSafeArea()
			VStack(spacing: 0) {
				Header()
				if newsService.isLoading {
					LoadingState()
				} else if filtered.isEmpty {
					EmptyState(icon: "newspaper", title: "No news", message: "Try a different category or search term.")
				} else {
					ListContent()
				}
			}
		}
		.navigationTitle("Gettysburg News")
		.navigationBarTitleDisplayMode(.large)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: { newsService.refresh() }) {
					Image(systemName: "arrow.clockwise")
				}
			}
		}
	}

	@ViewBuilder private func Header() -> some View {
		VStack(spacing: DesignSystem.Spacing.md) {
			HStack {
				HStack {
					Image(systemName: "magnifyingglass").foregroundColor(DesignSystem.Colors.textSecondary)
					TextField("Search news...", text: $searchText)
						.font(DesignSystem.Typography.body)
						.foregroundColor(DesignSystem.Colors.textPrimary)
					if !searchText.isEmpty {
						Button(action: { searchText = "" }) { Image(systemName: "xmark.circle.fill").foregroundColor(DesignSystem.Colors.textSecondary) }
					}
				}
				.padding(DesignSystem.Spacing.md)
				.background(.ultraThinMaterial)
				.clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
			}
			CategoryFilter()
		}
		.padding(.horizontal, DesignSystem.Spacing.lg)
		.padding(.top, DesignSystem.Spacing.lg)
	}

	@ViewBuilder private func CategoryFilter() -> some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: DesignSystem.Spacing.sm) {
				CategoryPill(title: "All", icon: "newspaper", selected: selectedCategory == nil, color: DesignSystem.Colors.blue) {
					selectedCategory = nil
				}
				ForEach(NewsCategory.allCases, id: \.self) { cat in
					CategoryPill(title: cat.rawValue, icon: cat.icon, selected: selectedCategory == cat, color: color(for: cat)) {
						selectedCategory = selectedCategory == cat ? nil : cat
					}
				}
			}
		}
	}

	private func color(for category: NewsCategory) -> Color {
		switch category {
		case .general: return DesignSystem.Colors.blue
		case .academic: return DesignSystem.Colors.success
		case .athletics: return DesignSystem.Colors.warning
		case .studentLife: return DesignSystem.Colors.purple
		case .announcements: return DesignSystem.Colors.error
		case .research: return DesignSystem.Colors.indigo
		}
	}

	@ViewBuilder private func ListContent() -> some View {
		ScrollView {
			LazyVStack(spacing: DesignSystem.Spacing.lg) {
				ForEach(filtered) { article in
					NavigationLink(destination: NewsDetailView(article: article)) {
						NewsRow(article: article)
					}
					.buttonStyle(PlainButtonStyle())
				}
			}
			.padding(.horizontal, DesignSystem.Spacing.lg)
			.padding(.bottom, 100)
		}
	}

	@ViewBuilder private func LoadingState() -> some View {
		VStack(spacing: DesignSystem.Spacing.lg) {
			ProgressView().progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.blue))
			Text("Loading news...")
				.font(DesignSystem.Typography.body)
				.foregroundColor(DesignSystem.Colors.textSecondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

private struct CategoryPill: View {
	let title: String
	let icon: String
	let selected: Bool
	let color: Color
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			HStack(spacing: DesignSystem.Spacing.xs) {
				Image(systemName: icon).font(.system(size: 12, weight: .semibold))
				Text(title).font(DesignSystem.Typography.caption.weight(.medium))
			}
			.padding(.horizontal, DesignSystem.Spacing.md)
			.padding(.vertical, DesignSystem.Spacing.sm)
			.background(
				Capsule().fill(selected ? color : Color.clear).background(.ultraThinMaterial)
			)
			.foregroundColor(selected ? .white : DesignSystem.Colors.textPrimary)
		}
		.buttonStyle(PlainButtonStyle())
	}
}

private struct NewsRow: View {
	let article: NewsArticle
	@State private var isPressed = false

	var body: some View {
		HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
			Thumbnail()
			VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
				HStack {
					CategoryBadge(category: article.category)
					Spacer()
					Text(article.timeAgo).font(DesignSystem.Typography.caption).foregroundColor(DesignSystem.Colors.textSecondary)
				}
				Text(article.title).font(DesignSystem.Typography.headline).foregroundColor(DesignSystem.Colors.textPrimary).lineLimit(2)
				if !article.shortSummary.isEmpty {
					Text(article.shortSummary).font(DesignSystem.Typography.footnote).foregroundColor(DesignSystem.Colors.textSecondary).lineLimit(2)
				}
			}
			Spacer(minLength: 0)
		}
		.padding(DesignSystem.Spacing.lg)
		.background(
			RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
				.fill(.ultraThinMaterial)
		)
		.overlay(
			RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
				.stroke(DesignSystem.Colors.cardBorder, lineWidth: 1)
		)
		.padding(.vertical, 4)
		.scaleEffect(isPressed ? 0.98 : 1.0)
		.animation(.spring(response: 0.5, dampingFraction: 0.8), value: isPressed)
		.contentShape(Rectangle())
		.onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
			withAnimation(DesignSystem.Animations.easeInOut) { isPressed = pressing }
		}, perform: {})
	}

	@ViewBuilder private func Thumbnail() -> some View {
		if let urlString = article.imageURL, let url = URL(string: urlString), !urlString.isEmpty {
			AsyncImage(url: url) { image in
				image.resizable().aspectRatio(contentMode: .fill)
					.frame(width: 80, height: 80)
					.clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
			} placeholder: {
				FallbackThumb()
			}
		} else { FallbackThumb() }
	}

	@ViewBuilder private func FallbackThumb() -> some View {
		ZStack {
			LinearGradient(colors: [DesignSystem.Colors.blue.opacity(0.3), DesignSystem.Colors.orange.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
			Image(systemName: "newspaper").font(.system(size: 32, weight: .light)).foregroundColor(.white.opacity(0.2))
		}
		.frame(width: 80, height: 80)
		.clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
	}
}

 


