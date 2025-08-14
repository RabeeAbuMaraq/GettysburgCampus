import SwiftUI

struct NewsHeroCard: View {
	let article: NewsArticle

	var body: some View {
		ZStack {
			BackgroundImage()
			GradientOverlay()
			ContentOverlay()
		}
		.frame(height: 240)
		.clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
		.shadow(color: .black.opacity(0.15), radius: 14, x: 0, y: 8)
		.accessibilityElement(children: .combine)
		.accessibilityLabel("Opens article: \(article.title)")
	}

	@ViewBuilder private func BackgroundImage() -> some View {
		if let urlString = article.imageURL, !urlString.isEmpty, let url = URL(string: urlString) {
			AsyncImage(url: url) { phase in
				if let image = phase.image {
					image.resizable().aspectRatio(contentMode: .fill).frame(maxWidth: .infinity).frame(height: 240).clipped()
				} else {
					Placeholder()
				}
			}
		} else {
			Placeholder()
		}
	}

	@ViewBuilder private func Placeholder() -> some View {
		LinearGradient(
			colors: [DesignSystem.Colors.blue.opacity(0.35), DesignSystem.Colors.orange.opacity(0.35)],
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
		.frame(maxWidth: .infinity)
		.frame(height: 240)
	}

	@ViewBuilder private func GradientOverlay() -> some View {
		LinearGradient(
			colors: [Color.black.opacity(0.0), Color.black.opacity(0.35), Color.black.opacity(0.75)],
			startPoint: .top,
			endPoint: .bottom
		)
	}

	@ViewBuilder private func ContentOverlay() -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Spacer()
			HStack {
				CategoryBadge(category: article.category)
				Spacer()
			}
			VStack(alignment: .leading, spacing: 6) {
				Text(article.title)
					.font(.title3.weight(.semibold))
					.foregroundColor(.white)
					.lineLimit(3)
				if !article.shortSummary.isEmpty {
					Text(article.shortSummary)
						.font(.footnote)
						.foregroundColor(.white.opacity(0.92))
						.lineLimit(2)
				}
				HStack {
					Text(article.timeAgo)
						.font(.caption)
						.foregroundColor(.white.opacity(0.85))
					Spacer()
					Image(systemName: "arrow.right")
						.font(.system(size: 13, weight: .semibold))
						.foregroundColor(.white.opacity(0.85))
				}
			}
			.padding(.horizontal, DesignSystem.Spacing.lg)
			.padding(.vertical, DesignSystem.Spacing.md)
			.background(
				RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
					.fill(Color.clear)
					.background(.ultraThinMaterial)
					.blur(radius: 0.5)
			)
		}
		.padding(DesignSystem.Spacing.lg)
	}
}


