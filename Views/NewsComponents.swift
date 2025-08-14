import SwiftUI

struct CategoryBadge: View {
	let category: NewsCategory
	var body: some View {
		HStack(spacing: DesignSystem.Spacing.xs) {
			Image(systemName: category.icon).font(.system(size: 10, weight: .semibold))
			Text(category.rawValue).font(DesignSystem.Typography.caption.weight(.medium))
		}
		.padding(.horizontal, DesignSystem.Spacing.sm)
		.padding(.vertical, DesignSystem.Spacing.xs)
		.background(Capsule().fill(color(for: category).opacity(0.9)))
		.foregroundColor(.white)
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
}


