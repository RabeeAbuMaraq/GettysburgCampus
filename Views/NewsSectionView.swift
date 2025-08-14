import SwiftUI

struct NewsSection: View {
    @StateObject private var newsService = NewsService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Campus News")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Spacer()
                NavigationLink(destination: NewsListView()) {
                    HStack(spacing: 6) {
                        Text("See all").font(DesignSystem.Typography.footnote.weight(.semibold))
                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(DesignSystem.Colors.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }

            if newsService.isLoading {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                    .fill(.ultraThinMaterial)
                    .frame(height: 240)
                    .overlay(ProgressView().progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.blue)))
            } else if newsService.articles.isEmpty {
                Text("No recent news")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            } else {
                TabView {
                    ForEach(Array(newsService.articles.prefix(4))) { article in
                        NavigationLink(destination: NewsDetailView(article: article)) {
                            NewsHeroCard(article: article)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 240)
            }
        }
    }
}


