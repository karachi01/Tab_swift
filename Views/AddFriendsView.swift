//
//  AddFriendsView.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/12/26.
//

import SwiftUI
import CoreLocation
import UIKit

struct AddFriendsView: View {
    @State private var friends: [Friend]
    @State private var newFriendName: String = ""
    @State private var newFriendContact: String = ""

    @Binding var path: NavigationPath
    @EnvironmentObject var tabManager: TabManager

    let restaurantName: String?
    let restaurantCoordinate: CLLocationCoordinate2D?

    let selectedImage: UIImage?
    let selectedIcon: String?
    @Binding var outingDate: Date // ✅ CHANGED

    

    init(
        initialFriends: [Friend],
        restaurantName: String?,
        restaurantCoordinate: CLLocationCoordinate2D?,
        selectedImage: UIImage?,
        selectedIcon: String?,
        outingDate: Binding<Date>,               // <-- Added this
        path: Binding<NavigationPath>
    ) {
        _friends = State(initialValue: initialFriends)
        self.restaurantName = restaurantName
        self.restaurantCoordinate = restaurantCoordinate
        self.selectedImage = selectedImage
        self.selectedIcon = selectedIcon
        _outingDate = outingDate     // <-- Assign the passed parameter
        _path = path
    }

    var body: some View {
        ZStack {

            // 🌿 Pastel background overlay
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

            VStack(spacing: 24) {

                // MARK: Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Add Friends")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 30/255, green: 60/255, blue: 55/255))

                    Text("Add friends and optionally their contact info for reminders.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 90/255, green: 120/255, blue: 110/255))
                }
                .padding(.horizontal)

                // MARK: Friends Scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(friends) { friend in
                            HStack(spacing: 6) {
                                Text(friend.isYou ? "You" : friend.name)
                                    .lineLimit(1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(friend.isYou ? Color.green.opacity(0.25) : Color.blue.opacity(0.2))
                                    )
                                    .foregroundStyle(friend.isYou ? .green : .blue)

                                if !friend.isYou {
                                    Button {
                                        friends.removeAll { $0.id == friend.id }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.blue)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 44)

                // MARK: Input Fields
                VStack(spacing: 12) {
                    TextField("Friend's Name", text: $newFriendName)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.95))
                                .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
                        )
                        .font(.system(size: 16, weight: .medium, design: .rounded))

                    TextField("Email or Phone (optional)", text: $newFriendContact)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.95))
                                .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
                        )
                        .font(.system(size: 16, weight: .medium, design: .rounded))

                    Button(action: addFriend) {
                        Text("Add Friend")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 70/255, green: 140/255, blue: 125/255),
                                        Color(red: 110/255, green: 180/255, blue: 160/255)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // MARK: Continue → WhoPaidView
                NavigationLink {
                    WhoPaidView(
                        friends: friends,
                        restaurantName: restaurantName,
                        selectedImage: selectedImage,
                        selectedIcon: selectedIcon,
                        outingDate: $outingDate, // ✅ Pass the outing date
                        path: $path
                    )
                    .environmentObject(tabManager)
                } label: {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, maxHeight: 52)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 70/255, green: 140/255, blue: 125/255),
                                    Color(red: 110/255, green: 180/255, blue: 160/255)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Add Friends")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addFriend() {
        let trimmed = newFriendName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        friends.append(
            Friend(
                name: trimmed,
                contactInfo: newFriendContact.isEmpty ? nil : newFriendContact
            )
        )

        newFriendName = ""
        newFriendContact = ""
    }
}
