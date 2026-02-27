
//
//  OutingDraft.swift
//  Tab
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


    func reset() {
        locationName = ""
        outingDate = .now
        selectedImage = nil
        selectedIcon = nil
        friends = [Friend(name: "You", isYou: true)]
    }
}
