//
//  TabDetailView.swift
//  Tab
//


import SwiftUI
import MapKit
import UIKit

struct TabDetailView: View {
    let tabID: UUID
    @EnvironmentObject var tabManager: TabManager
    @Binding var path: NavigationPath

    @State private var isSettling = false
    @State private var showSettledCheck = false
    @State private var showDeleteConfirmation = false


    private var heroHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 380 : 240
    }

    private var tab: Tab? {
        tabManager.tabs.first { $0.id == tabID }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            if let tab {
                ScrollView {
                    VStack(spacing: 20) {

  
                        ZStack(alignment: .bottomLeading) {
                            heroVisual(tab: tab)
                                .frame(maxWidth: .infinity)
                                .frame(height: heroHeight)
                                .clipped()

                            LinearGradient(
                                colors: [.clear, .black.opacity(0.55)],
                                startPoint: .center,
                                endPoint: .bottom
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(tab.restaurantName)
                                    .font(.system(.title, design: .rounded, weight: .heavy))
                                    .foregroundColor(.white)

                                Text(tab.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.system(.footnote, design: .rounded, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding()
                        }
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)


                        VStack(alignment: .leading, spacing: 12) {
                            Text("Breakdown")
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color(.label))
                                .padding(.horizontal)

                            ForEach(tab.friends) { friend in
                                HStack(spacing: 12) {
                                    Text(friend.isYou ? "You" : friend.name)
                                        .font(.system(.callout, design: .rounded, weight: .medium))
                                        .foregroundStyle(Color(.label))

                                    Spacer()

                                    Text(friend.owesAmount, format: .currency(code: "USD"))
                                        .font(.system(.callout, design: .rounded, weight: .semibold))
                                        .foregroundStyle(friend.owesAmount == 0 ? .green : Color(.label))

                                    if !friend.isYou && friend.owesAmount > 0 {
                                        if tab.hasReminded(friendID: friend.id) {
                                            Label("Sent", systemImage: "checkmark.circle.fill")
                                                .font(.system(.caption, design: .rounded, weight: .medium))
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
                                                    .font(.system(.caption, design: .rounded, weight: .semibold))
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
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                                .padding(.horizontal)
                            }
                        }


                        HStack {
                            Text("Total")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Text(tab.totalAmount, format: .currency(code: "USD"))
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(Color(.label))
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        .padding(.horizontal)


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
                                        .font(.system(.title, design: .rounded, weight: .semibold))
                                        .foregroundStyle(.white)
                                } else {
                                    Text(tab.isSettled ? "Mark as Active" : "Mark as Settled")
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .disabled(isSettling)
                        .padding(.horizontal)


                        Button {
                            path.append(EditTabPath(tabID: tabID))
                        } label: {
                            Text("Edit Tab")
                                .font(.system(.headline, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.15))
                                .foregroundStyle(.green)
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }


                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            Text("Delete Tab")
                                .font(.system(.headline, design: .rounded))
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
        .alert("Delete Tab?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                tabManager.delete(tabID: tabID)
                var transaction = Transaction()
                transaction.animation = nil
                withTransaction(transaction) {
                    path.removeLast()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This tab will be permanently deleted and cannot be recovered.")
        }
    }

    @ViewBuilder
    private func heroVisual(tab: Tab) -> some View {
        if let data = tab.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if let icon = tab.iconName {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .padding(40)
                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
        } else {
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(40)
                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
        }
    }
}
