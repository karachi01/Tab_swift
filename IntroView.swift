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
    
    var body: some View {
        ZStack {
            // 🌿 Pastel background gradient using #F1EFE4 theme
            LinearGradient(
                colors: [
                    Color(red: 241/255, green: 239/255, blue: 228/255),   // #F1EFE4 base
                    Color(red: 230/255, green: 238/255, blue: 235/255),   // soft sage tint
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icon with subtle contrast bubble
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.7))   // lighter bubble for contrast
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 3)
                    
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            Color(red: 70/255, green: 110/255, blue: 105/255) // deeper muted teal
                        )
                }
                
                VStack(spacing: 12) {
                    Text("Tab")
                        .font(.system(size: 38, weight: .heavy, design: .rounded)) // friendly rounded font
                        .foregroundStyle(Color(red: 30/255, green: 60/255, blue: 55/255)) // slightly deeper contrast
                    
                    Text("A gentle way to split bills and keep friendships easy.")
                        .font(.system(size: 17, weight: .medium, design: .rounded)) // readable, soft
                        .foregroundStyle(Color(red: 90/255, green: 120/255, blue: 110/255)) // soft muted teal for subtext
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                NavigationLink(value: "home") {
                    HStack {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 95/255, green: 145/255, blue: 135/255), // richer sage-teal
                                Color(red: 130/255, green: 175/255, blue: 165/255) // soft mint-teal
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding()
        }
    }
}
