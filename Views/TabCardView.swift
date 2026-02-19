//
//  TabCardView.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/12/26.
//

import SwiftUI
import UIKit

struct TabCardView: View {
    @Binding var tab: Tab

    private let cornerRadius: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Header
            ZStack(alignment: .bottomLeading) {
                visualHeader
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(tab.restaurantName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Text(tab.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
            }

            // MARK: Details
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Amount")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                Text(tab.totalAmount, format: .currency(code: "USD"))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))

                Text("People")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                Text(tab.friends.map { $0.name }.joined(separator: ", "))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        // ⬇️ This clips EVERYTHING inside to rounded corners
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

        // ⬇️ Background + shadow sit behind the clipped content
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )

        // Keeps the whole card tappable with the same shape
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    // MARK: Visual Header
    @ViewBuilder
    private var visualHeader: some View {
        if let data = tab.imageData,
           let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()

        } else if let icon = tab.iconName {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .padding(30)
                .foregroundStyle(.blue.opacity(0.7))
                .background(Color(.systemGray6))

        } else {
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(30)
                .foregroundStyle(.red.opacity(0.6))
                .background(Color(.systemGray6))
        }
    }
}

