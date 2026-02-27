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


                        VStack(alignment: .leading, spacing: 6) {
                            Text("Add Friends")
                                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                                .foregroundStyle(Color(.label))

                            Text("Add friends and optionally their contact info for reminders.")
                                .font(.system(.body, design: .rounded, weight: .medium))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        .padding(.horizontal)


                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(draft.friends) { friend in
                                    HStack(spacing: 6) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(friend.isYou ? "You" : friend.name)
                                                .lineLimit(1)
                                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                                .foregroundStyle(friend.isYou ? .green : .blue)

                                            if let contact = friend.contactInfo, !contact.isEmpty {
                                                Text(contact)
                                                    .lineLimit(1)
                                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                                    .foregroundStyle(friend.isYou ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(friend.isYou ? Color.green.opacity(0.15) : Color.blue.opacity(0.12))
                                        )

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
                        .frame(height: 60)

 
                        VStack(spacing: 20) {
                            TextField("Friend's Name", text: $newFriendName)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
                                )
                                .font(.system(.callout, design: .rounded, weight: .medium))
                                .foregroundStyle(Color(.label))
                                .focused($isKeyboardFocused)

                            Button(action: addFriend) {
                                Text("Add Friend")
                                    .font(.system(.headline, design: .rounded))
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


                Button {
                    isKeyboardFocused = false
                    path.append("whoPaid")
                } label: {
                    Text("Continue")
                        .font(.system(.headline, design: .rounded))
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
