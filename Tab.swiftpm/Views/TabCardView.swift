//
//  TabCardView.swift
//  Tab
//


import SwiftUI
import UIKit

struct TabCardView: View {
    @Binding var tab: Tab
    @Environment(\.colorScheme) var colorScheme

    private let cornerRadius: CGFloat = 20

    private var headerHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 200 : 140
    }

    var body: some View {
        VStack(spacing: 0) {


            ZStack(alignment: .bottomLeading) {
                visualHeader
                    .frame(height: headerHeight)
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


            Rectangle()
                .fill(colorScheme == .dark
                      ? Color(red: 70/255, green: 140/255, blue: 125/255).opacity(0.35)
                      : Color(.separator).opacity(0.2))
                .frame(height: 1)


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
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )

        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    colorScheme == .dark
                        ? Color(red: 70/255, green: 140/255, blue: 125/255).opacity(0.25)
                        : Color.clear,
                    lineWidth: 1
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 8 : 0)
    }


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
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                .background(colorScheme == .dark
                            ? Color(.systemGray5)
                            : Color(.systemGray6))

        } else {
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(30)
                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(colorScheme == .dark
                            ? Color(.systemGray5)
                            : Color(.systemGray6))
        }
    }
}
