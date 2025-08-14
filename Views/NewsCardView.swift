import SwiftUI

// Compact horizontal card used on Home and in lists
struct NewsCardView: View {
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
				Text(article.title)
					.font(DesignSystem.Typography.headline)
					.foregroundColor(DesignSystem.Colors.textPrimary)
					.lineLimit(2)
				if !article.shortSummary.isEmpty {
					Text(article.shortSummary)
						.font(DesignSystem.Typography.footnote)
						.foregroundColor(DesignSystem.Colors.textSecondary)
						.lineLimit(2)
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


