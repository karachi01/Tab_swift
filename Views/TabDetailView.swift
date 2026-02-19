//
//  TabDetailView.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/12/26.
//

import SwiftUI
import MapKit
import UIKit   // ✅ For haptics

struct TabDetailView: View {
    let tabID: UUID
    @EnvironmentObject var tabManager: TabManager
    @Binding var path: NavigationPath

    // Settling animation state
    @State private var isSettling = false
    @State private var showSettledCheck = false

    private var tab: Tab? {
        tabManager.tabs.first { $0.id == tabID }
    }

    var body: some View {
        ZStack {
            // 🌿 Same pastel background as HomeView
            Color.white
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color(red: 241/255, green: 239/255, blue: 228/255).opacity(0.15),
                            Color(red: 230/255, green: 238/255, blue: 235/255).opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let tab {
                ScrollView {
                    VStack(spacing: 20) {

                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text(tab.restaurantName)
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundStyle(Color(red: 30/255, green: 60/255, blue: 55/255))

                            Text(tab.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(red: 90/255, green: 120/255, blue: 110/255))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                        // Breakdown Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Breakdown")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .padding(.horizontal)

                            ForEach(tab.friends) { friend in
                                HStack(spacing: 12) {
                                    Text(friend.isYou ? "You" : friend.name)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))

                                    Spacer()

                                    Text(friend.owesAmount, format: .currency(code: "USD"))
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(friend.owesAmount == 0 ? .green : .primary)

                                    if !friend.isYou && friend.owesAmount > 0 {
                                        if tab.hasReminded(friendID: friend.id) {
                                            Label("Sent", systemImage: "checkmark.circle.fill")
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundStyle(.green)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color.green.opacity(0.15))
                                                .clipShape(Capsule())
                                        } else {
                                            Button {
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()

                                                tabManager.markFriendReminded(
                                                    tabID: tab.id,
                                                    friendID: friend.id
                                                )
                                            } label: {
                                                Label("Remind", systemImage: "bell.fill")
                                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(
                                                        LinearGradient(
                                                            colors: [.green, .teal],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .clipShape(Capsule())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))   // 🧼 card surface
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                                .padding(.horizontal)
                            }
                        }

                        // Total Card
                        HStack {
                            Text("Total")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            Spacer()
                            Text(tab.totalAmount, format: .currency(code: "USD"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        .padding(.horizontal)

                        // ✅ Settle / Active Toggle Button
                        Button(action: {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)

                            if tab.isSettled {
                                tabManager.markTabActive(tabID: tab.id)
                                path.removeLast(path.count - 1)
                            } else {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isSettling = true
                                    showSettledCheck = true
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    tabManager.markTabSettled(tabID: tabID)

                                    var transaction = Transaction()
                                    transaction.animation = nil
                                    withTransaction(transaction) {
                                        path.removeLast()
                                    }
                                }
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        tab.isSettled
                                        ? Color(red: 70/255, green: 140/255, blue: 125/255)
                                        : (isSettling
                                           ? Color.green.opacity(0.7)
                                           : Color(red: 70/255, green: 140/255, blue: 125/255))
                                    )
                                    .frame(height: 52)

                                if !tab.isSettled && showSettledCheck {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)
                                } else {
                                    Text(tab.isSettled ? "Mark as Active" : "Mark as Settled")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .disabled(isSettling)
                        .padding(.horizontal)

                        // Edit
                        Button {
                            path.append(EditTabPath(tabID: tabID))
                        } label: {
                            Text("Edit Tab")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.15))
                                .foregroundStyle(.green)
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }

                        // Delete
                        Button {
                            tabManager.delete(tabID: tabID)

                            var transaction = Transaction()
                            transaction.animation = nil
                            withTransaction(transaction) {
                                path.removeLast()
                            }
                        } label: {
                            Text("Delete Tab")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.15))
                                .foregroundStyle(.red)
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Tab Details")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
