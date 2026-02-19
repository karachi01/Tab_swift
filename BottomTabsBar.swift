//
//  BottomTabsBar.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/14/26.
//

import SwiftUI

struct BottomTabsBar: View {
    @Binding var selected: HomeTabSection

    var body: some View {
        HStack(spacing: 6) {
            tabItem(
                title: "Your Tabs",
                systemImage: "list.bullet",
                isActive: selected == .active
            ) {
                selected = .active
            }

            tabItem(
                title: "Settled",
                systemImage: "checkmark.circle",
                isActive: selected == .settled
            ) {
                selected = .settled
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    LinearGradient(
                        colors: [
                            Color(red: 241/255, green: 239/255, blue: 228/255).opacity(0.25),
                            Color(red: 230/255, green: 238/255, blue: 235/255).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
        )
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    private func tabItem(
        title: String,
        systemImage: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))

                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(
                isActive
                ? Color.white
                : Color(red: 90/255, green: 120/255, blue: 110/255)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isActive {
                        LinearGradient(
                            colors: [
                                Color(red: 70/255, green: 140/255, blue: 125/255),
                                Color(red: 110/255, green: 180/255, blue: 160/255)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
