//
//  TabManager.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/12/26.
//

import SwiftUI

class TabManager: ObservableObject {
    @Published var tabs: [Tab] = [] {
        didSet {
            saveTabs()
        }
    }

    private let saveKey = "saved_tabs"

    init() {
        loadTabs()
    }

    // MARK: - Public Actions

    func update(tab: Tab) {
        var updatedTab = tab
        updatedTab.recalcTotal()

        if let index = tabs.firstIndex(where: { $0.id == updatedTab.id }) {
            tabs[index] = updatedTab
        }
    }

    func markFriendReminded(tabID: UUID, friendID: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        tabs[index].markReminded(friendID: friendID)
    }

    func markTabSettled(tabID: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        tabs[index].isSettled = true
    }

    // ✅ NEW: Move Settled → Active
    func markTabActive(tabID: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        tabs[index].isSettled = false
    }


    // MARK: - Persistence

    private func saveTabs() {
        do {
            let data = try JSONEncoder().encode(tabs)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("❌ Failed to save tabs:", error)
        }
    }

    private func loadTabs() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }

        do {
            tabs = try JSONDecoder().decode([Tab].self, from: data)
        } catch {
            print("❌ Failed to load tabs:", error)
            tabs = []
        }
    }

    func delete(tabID: UUID) {
        tabs.removeAll { $0.id == tabID }
    }
}
