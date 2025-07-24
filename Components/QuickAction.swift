//
//  QuickAction.swift
//  GettysburgCampus
//
//  Created by Rabee AbuMaraq on 7/18/25.
//


import SwiftUI

struct QuickAction: View {
    var name: String
    var systemIcon: String

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.themeCard)
                .frame(width: 50, height: 50)
                .shadow(color: Color.themeSeparator.opacity(0.10), radius: 4, x: 0, y: 2)
                .overlay(
                    Image(systemName: systemIcon)
                        .foregroundColor(.black)
                )
            Text(name)
                .font(.caption)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(width: 60)
        }
    }
}
