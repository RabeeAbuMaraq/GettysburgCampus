import SwiftUI

struct NewsSection: View {
	@StateObject private var newsService = NewsService.shared
	@State private var animateNews = false

	var body: some View {
		VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
			HStack {
				Text("Gettysburg News")
					.font(DesignSystem.Typography.title3)
					.foregroundColor(DesignSystem.Colors.textPrimary)
				Spacer()
				if newsService.isLoading { ProgressView().scaleEffect(0.8).progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.blue)) }
			}

			if newsService.articles.isEmpty && !newsService.isLoading {
				EmptyState(icon: "newspaper", title: "No news available", message: "Check back later for the latest updates")
			} else {
				VStack(spacing: DesignSystem.Spacing.md) {
					ForEach(Array(newsService.articles.prefix(3).enumerated()), id: \.element.id) { index, article in
						NavigationLink(destination: NewsDetailView(article: article)) {
							NewsCardView(article: article)
								.opacity(animateNews ? 1 : 0)
								.offset(y: animateNews ? 0 : 30)
								.animation(DesignSystem.Animations.spring.delay(Double(index) * 0.1), value: animateNews)
						}
						.buttonStyle(PlainButtonStyle())
					}
				}
				NavigationLink(destination: NewsListView()) {
					HStack {
						Text("View All News").font(DesignSystem.Typography.footnote.weight(.semibold)).foregroundColor(DesignSystem.Colors.blue)
						Spacer()
						Text("\(newsService.articles.count) articles").font(DesignSystem.Typography.caption).foregroundColor(DesignSystem.Colors.textSecondary)
						Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(DesignSystem.Colors.blue)
					}
					.padding(.horizontal, DesignSystem.Spacing.lg)
					.padding(.vertical, DesignSystem.Spacing.md)
					.glassCard()
				}
				.buttonStyle(PlainButtonStyle())
			}
		}
		.onAppear { withAnimation(DesignSystem.Animations.spring.delay(0.7)) { animateNews = true } }
	}
}


