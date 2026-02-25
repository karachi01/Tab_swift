//
//  AddFriendsView.swift
//  Tab
//

import SwiftUI
import CoreLocation
import UIKit

struct AddFriendsView: View {
    @EnvironmentObject var draft: OutingDraft
    @EnvironmentObject var tabManager: TabManager
    @Binding var path: NavigationPath

    @State private var newFriendName: String = ""
    @State private var newFriendContact: String = ""
    @FocusState private var isKeyboardFocused: Bool

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {

                        // MARK: Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Add Friends")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundStyle(Color(red: 30/255, green: 60/255, blue: 55/255))

                            Text("Add friends and optionally their contact info for reminders.")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        .padding(.horizontal)

                        // MARK: Friends chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(draft.friends) { friend in
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
                                                draft.friends.removeAll { $0.id == friend.id }
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
                                        .fill(Color(.secondarySystemBackground))
                                        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
                                )
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(.label))
                                .focused($isKeyboardFocused)

                            TextField("Email or Phone (optional)", text: $newFriendContact)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
                                )
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(.label))
                                .focused($isKeyboardFocused)

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

                        Color.clear.frame(height: 20)
                    }
                    .padding(.top)
                }

                // MARK: Continue — pinned, keyboard slides over
                Button {
                    isKeyboardFocused = false
                    path.append("whoPaid")
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
                .padding(.top, 12)
                // Use systemBackground so the pinned button area matches the screen in both modes
                .background(Color(.systemBackground))
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle("Add Friends")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isKeyboardFocused = false }
            }
        }
        .onTapGesture { isKeyboardFocused = false }
    }

    private func addFriend() {
        let trimmed = newFriendName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        draft.friends.append(
            Friend(name: trimmed, contactInfo: newFriendContact.isEmpty ? nil : newFriendContact)
        )
        newFriendName = ""
        newFriendContact = ""
    }
}
