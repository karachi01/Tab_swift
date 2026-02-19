
//
//  OutingDraft.swift
//  Tab
//
//  Holds in-progress state for the outing creation flow.
//  Injected as an environment object so every step in
//  Create → AddFriends → WhoPaid can read/write shared state
//  without fragile @Binding chains through NavigationLink(destination:).
//

import SwiftUI
import UIKit
import CoreLocation

class OutingDraft: ObservableObject {
    @Published var locationName: String = ""
    @Published var outingDate: Date = .now
    @Published var selectedImage: UIImage?
    @Published var selectedIcon: String?
    @Published var friends: [Friend] = [Friend(name: "You", isYou: true)]

    /// Call when the user finishes or cancels the creation flow
    /// to prepare for the next one.
    func reset() {
        locationName = ""
        outingDate = .now
        selectedImage = nil
        selectedIcon = nil
        friends = [Friend(name: "You", isYou: true)]
    }
}
