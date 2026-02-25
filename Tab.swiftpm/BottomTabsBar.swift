//
//  BottomTabsBar.swift
//  Tab
//

import SwiftUI

struct BottomTabsBar: View {
    @Binding var selected: HomeTabSection

    var body: some View {
        HStack(spacing: 6) {
            tabItem(title: "Your Tabs", systemImage: "list.bullet", isActive: selected == .active) {
                selected = .active
            }
            tabItem(title: "Settled", systemImage: "checkmark.circle", isActive: selected == .settled) {
                selected = .settled
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
        )
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        // Fills the gap between the pill and the screen bottom (home indicator area)
        // with the page background so there's no faint box visible in dark mode
        .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
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
                : Color(.secondaryLabel)
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
