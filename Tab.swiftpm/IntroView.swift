//
//  IntroView.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/12/26.
//

import SwiftUI
import UIKit

struct IntroView: View {
    @Binding var path: NavigationPath
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Light mode: original pastel gradient exactly as before
            // Dark mode: system dark background with same subtle tint
            if colorScheme == .dark {
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color(red: 241/255, green: 239/255, blue: 228/255).opacity(0.06),
                                Color(red: 230/255, green: 238/255, blue: 235/255).opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 241/255, green: 239/255, blue: 228/255),
                        Color(red: 230/255, green: 238/255, blue: 235/255),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 32) {
                Spacer()

                // Icon bubble
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : Color.white.opacity(0.7))
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 3)

                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color(red: 70/255, green: 110/255, blue: 105/255))
                }

                VStack(spacing: 12) {
                    Text("Tab")
                        .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                        .foregroundStyle(colorScheme == .dark ? Color(.label) : Color(red: 30/255, green: 60/255, blue: 55/255))

                    Text("A gentle way to split bills and keep friendships easy.")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(colorScheme == .dark ? Color(.label) : Color(red: 30/255, green: 60/255, blue: 55/255))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .lineSpacing(4)
                }

                Spacer()

                // Use a plain Button + path.append instead of NavigationLink
                // to avoid the default NavigationLink background that causes
                // the black box at small Dynamic Type sizes
                Button {
                    path.append("home")
                } label: {
                    HStack {
                        Text("Get Started")
                            .font(.system(.headline, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(.headline, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 95/255, green: 145/255, blue: 135/255),
                                Color(red: 130/255, green: 175/255, blue: 165/255)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding()
        }
    }
}
