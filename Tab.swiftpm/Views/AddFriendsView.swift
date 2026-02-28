//
//  AddFriendsView.swift
//  Tab
//

import SwiftUI
import CoreLocation
import UIKit

enum AddFriendsField {
    case name
}

struct AddFriendsView: View {
    @EnvironmentObject var draft: OutingDraft
    @EnvironmentObject var tabManager: TabManager
    @Binding var path: NavigationPath

    @State private var newFriendName: String = ""
    @State private var newFriendContact: String = ""
    // Typed FocusState avoids the iPad floating-keyboard issue that a plain
    // Bool @FocusState can trigger
    @FocusState private var focusedField: AddFriendsField?

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {

                        // MARK: Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Add Friends")
                                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                                .foregroundStyle(Color(.label))

                            Text("Who are you splitting with?")
                                .font(.system(.body, design: .rounded, weight: .medium))
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
                                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                            .foregroundStyle(friend.isYou ? .green : .blue)
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
                        .frame(height: 50)

                        // MARK: Input + Add button
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
                                // Typed focus — no floating keyboard on iPad
                                .focused($focusedField, equals: .name)
                                .submitLabel(.done)
                                .onSubmit { addFriend() }

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
                            // .plain keeps the gradient background visible and
                            // prevents the system from swallowing the tap
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)

                        Color.clear.frame(height: 20)
                    }
                    .padding(.top, 4)
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture { focusedField = nil }

                // MARK: Continue — pinned bottom
                Button {
                    focusedField = nil
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
                .buttonStyle(.plain)
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
                Button("Done") { focusedField = nil }
            }
        }
    }

    private func addFriend() {
        let trimmed = newFriendName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        draft.friends.append(
            Friend(name: trimmed, contactInfo: nil)
        )
        newFriendName = ""
        // Keep keyboard open so user can quickly add another friend
    }
}
