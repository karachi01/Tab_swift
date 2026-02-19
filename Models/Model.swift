//
//  Model.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/12/26.
//

import Foundation

// MARK: - Friend model
struct Friend: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var contactInfo: String?
    var paidAmount: Double
    var owesAmount: Double
    var isYou: Bool
    var customTip: Double

    init(
        id: UUID = UUID(),
        name: String,
        contactInfo: String? = nil,
        owesAmount: Double = 0.0,
        paidAmount: Double = 0.0,
        isYou: Bool = false,
        customTip: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.contactInfo = contactInfo
        self.owesAmount = owesAmount
        self.paidAmount = paidAmount
        self.isYou = isYou
        self.customTip = customTip
    }
}

// MARK: - Tab model
struct Tab: Identifiable, Hashable, Codable {
    let id: UUID
    var restaurantName: String
    var date: Date
    var totalAmount: Double
    var friends: [Friend]

    var imageData: Data?
    var iconName: String?
    var isSettled: Bool
    var remindedFriendIDs: Set<UUID>

    init(
        id: UUID = UUID(),
        restaurantName: String,
        date: Date = .now,
        totalAmount: Double = 0,
        friends: [Friend],
        imageData: Data? = nil,
        iconName: String? = nil,
        isSettled: Bool = false,
        remindedFriendIDs: Set<UUID> = []
    ) {
        self.id = id
        self.restaurantName = restaurantName
        self.date = date
        self.totalAmount = totalAmount
        self.friends = friends
        self.imageData = imageData
        self.iconName = iconName
        self.isSettled = isSettled
        self.remindedFriendIDs = remindedFriendIDs
    }

    mutating func markReminded(friendID: UUID) {
        remindedFriendIDs.insert(friendID)
    }

    func hasReminded(friendID: UUID) -> Bool {
        remindedFriendIDs.contains(friendID)
    }

    mutating func recalcTotal() {
        totalAmount = friends.reduce(0) { $0 + $1.owesAmount }
    }
    
    static func == (lhs: Tab, rhs: Tab) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
}
