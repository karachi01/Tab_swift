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
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)

                    Text(tab.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
            }

            // MARK: Details
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Amount")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(tab.totalAmount, format: .currency(code: "USD"))
                    .font(.system(.title3, design: .rounded, weight: .semibold))

                Text("People")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(tab.friends.map { $0.name }.joined(separator: ", "))
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                // systemBackground = white in light mode (unchanged),
                // elevated dark surface in dark mode — pops off secondarySystemBackground
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
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
                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))

                .background(Color(.systemGray6))

        } else {
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(30)
                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))
                .background(Color(.systemGray6))
        }
    }
}
