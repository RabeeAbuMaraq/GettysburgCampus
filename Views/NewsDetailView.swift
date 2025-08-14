import SwiftUI
import SafariServices

struct NewsDetailView: View {
	let article: NewsArticle
	@Environment(\.presentationMode) private var presentationMode
	@State private var showSafari = false
	@State private var animateContent = false

	var body: some View {
		ZStack {
			DesignSystem.Colors.backgroundGradient.ignoresSafeArea()
			ScrollView {
				VStack(spacing: 0) {
					Hero()
					VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
						Header()
						DividerView()
						Content()
						PrimaryButton()
						Spacer(minLength: 100)
					}
					.opacity(animateContent ? 1 : 0)
					.offset(y: animateContent ? 0 : 20)
				}
			}
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				Button(action: { presentationMode.wrappedValue.dismiss() }) {
					Image(systemName: "chevron.left")
						.font(.system(size: 18, weight: .semibold))
						.foregroundColor(DesignSystem.Colors.textPrimary)
						.frame(width: 40, height: 40)
						.background(.ultraThinMaterial)
						.clipShape(Circle())
				}
			}
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: { showSafari = true }) {
					Image(systemName: "safari")
						.font(.system(size: 16, weight: .semibold))
						.foregroundColor(DesignSystem.Colors.textPrimary)
						.frame(width: 40, height: 40)
						.background(.ultraThinMaterial)
						.clipShape(Circle())
				}
			}
		}
		.onAppear { withAnimation(DesignSystem.Animations.spring.delay(0.2)) { animateContent = true } }
		.sheet(isPresented: $showSafari) { SafariView(url: URL(string: article.articleURL)!) }
	}

	@ViewBuilder private func Hero() -> some View {
		ZStack {
			if let urlString = article.imageURL, !urlString.isEmpty, let url = URL(string: urlString) {
				AsyncImage(url: url) { phase in
					if let image = phase.image { image.resizable().aspectRatio(contentMode: .fill).frame(height: 300).clipped() }
					else { Placeholder() }
				}
			} else { Placeholder() }
			LinearGradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.3), Color.black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
		}
	}

	@ViewBuilder private func Placeholder() -> some View {
		Rectangle().fill(LinearGradient(colors: [DesignSystem.Colors.blue.opacity(0.3), DesignSystem.Colors.orange.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(height: 300)
	}

	@ViewBuilder private func Header() -> some View {
		VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
			HStack {
				CategoryBadge(category: article.category)
				Spacer()
				Text(article.formattedDate).font(DesignSystem.Typography.caption).foregroundColor(DesignSystem.Colors.textSecondary)
			}
			Text(article.title).font(DesignSystem.Typography.title1.weight(.bold)).foregroundColor(DesignSystem.Colors.textPrimary)
			Text(article.timeAgo).font(DesignSystem.Typography.footnote).foregroundColor(DesignSystem.Colors.textSecondary)
		}
		.padding(.horizontal, DesignSystem.Spacing.lg)
		.padding(.top, DesignSystem.Spacing.lg)
	}

	@ViewBuilder private func DividerView() -> some View {
		Rectangle().fill(DesignSystem.Colors.textTertiary.opacity(0.2)).frame(height: 1).padding(.horizontal, DesignSystem.Spacing.lg)
	}

	@ViewBuilder private func Content() -> some View {
		VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
			Text(article.content)
				.font(DesignSystem.Typography.body)
				.foregroundColor(DesignSystem.Colors.textPrimary)
				.lineSpacing(6)
		}
		.padding(.horizontal, DesignSystem.Spacing.lg)
	}

	@ViewBuilder private func PrimaryButton() -> some View {
		Button(action: { showSafari = true }) {
			HStack {
				Image(systemName: "safari").font(.system(size: 16, weight: .semibold))
				Text("Read Full Article").font(DesignSystem.Typography.headline.weight(.semibold))
				Spacer()
				Image(systemName: "arrow.up.right").font(.system(size: 14, weight: .semibold))
			}
			.foregroundColor(.white)
			.padding(DesignSystem.Spacing.lg)
			.background(
				RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
					.fill(LinearGradient(colors: [DesignSystem.Colors.blue, DesignSystem.Colors.orange], startPoint: .leading, endPoint: .trailing))
			)
		}
		.buttonStyle(PlainButtonStyle())
		.padding(.horizontal, DesignSystem.Spacing.lg)
		.padding(.top, DesignSystem.Spacing.md)
	}
}

struct SafariView: UIViewControllerRepresentable {
	let url: URL
	func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
	func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}


