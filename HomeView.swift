//
//  HomeView.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/12/26.
//

import SwiftUI
import MapKit

enum HomeTabSection {
    case active
    case settled
}

enum HomeDisplayMode {
    case list
    case monthly
}

struct HomeView: View {
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var draft: OutingDraft
    @Binding var path: NavigationPath

    @State private var selectedSection: HomeTabSection = .active
    @State private var displayMode: HomeDisplayMode = .list
    @State private var expandedMonths: Set<String> = []

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            // Background
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

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(selectedSection == .active ? "Your Tabs" : "Settled Tabs")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(red: 30/255, green: 60/255, blue: 55/255))

                        Text(
                            selectedSection == .active
                            ? "Shared moments, settled gently."
                            : "Memories already taken care of."
                        )
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 90/255, green: 120/255, blue: 110/255))
                    }
                    .padding(.horizontal)

                    // MARK: View Toggle
                    viewToggle

                    // MARK: Content
                    if filteredTabs.isEmpty {
                        emptyState
                    } else {
                        if displayMode == .list {
                            tabsTimeline
                        } else {
                            monthlyFolders
                        }
                    }
                }
                .padding(.top)
                .padding(.bottom, 90)
            }
            .id(selectedSection)

            BottomTabsBar(selected: $selectedSection)

            // MARK: Floating "+" Button — now path-tracked
            if selectedSection == .active {
                Button {
                    draft.reset()
                    path.append("create")
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 70/255, green: 140/255, blue: 125/255),
                                        Color(red: 110/255, green: 180/255, blue: 160/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.black.opacity(0.15), radius: 6, y: 3)

                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, 90)
            }
        }
    }
}

private extension HomeView {

    // MARK: Existing Logic (UNCHANGED)

    var filteredTabs: [Binding<Tab>] {
        switch selectedSection {
        case .active:
            return $tabManager.tabs.filter { !$0.wrappedValue.isSettled }
        case .settled:
            return $tabManager.tabs.filter { $0.wrappedValue.isSettled }
        }
    }

    // MARK: View Toggle

    var viewToggle: some View {
        HStack {
            Button {
                displayMode = .list
            } label: {
                Text("List")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(displayMode == .list ? Color.green.opacity(0.2) : Color.clear)
                    .cornerRadius(20)
            }

            Button {
                displayMode = .monthly
            } label: {
                Text("Monthly")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(displayMode == .monthly ? Color.green.opacity(0.2) : Color.clear)
                    .cornerRadius(20)
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: Monthly Grouping

    var monthlyFolders: some View {
        let grouped = Dictionary(grouping: filteredTabs) {
            monthString(from: $0.wrappedValue.date)
        }

        let sortedKeys = grouped.keys.sorted { lhs, rhs in
            monthDate(from: lhs) > monthDate(from: rhs)
        }

        return LazyVStack(spacing: 14) {
            ForEach(sortedKeys, id: \.self) { month in

                let tabsForMonth = grouped[month] ?? []

                VStack(alignment: .leading, spacing: 8) {

                    Button {
                        if expandedMonths.contains(month) {
                            expandedMonths.remove(month)
                        } else {
                            expandedMonths.insert(month)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "folder.fill")
                            Text(month)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            Spacer()
                            Image(systemName:
                                    expandedMonths.contains(month)
                                    ? "chevron.down"
                                    : "chevron.right"
                            )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.08), radius: 6)
                        )
                    }
                    .buttonStyle(.plain)

                    if expandedMonths.contains(month) {
                        LazyVStack(spacing: 16) {
                            ForEach(tabsForMonth) { $tab in
                                NavigationLink(value: tab.id) {
                                    TabCardView(tab: $tab)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: Date Helpers (UI Only)

    func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    func monthDate(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.date(from: string) ?? Date()
    }

    // MARK: Existing Views (UNCHANGED)

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color(red: 40/255, green: 90/255, blue: 80/255))

            Text("No tabs here")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 30/255, green: 60/255, blue: 55/255))

            Text(
                selectedSection == .active
                ? "Start a tab with friends to see it here."
                : "Tabs you settle will appear here."
            )
            .font(.system(size: 17, weight: .medium, design: .rounded))
            .foregroundStyle(Color(red: 90/255, green: 120/255, blue: 110/255))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .lineSpacing(4)

            if selectedSection == .active {
                Button {
                    draft.reset()
                    path.append("create")
                } label: {
                    Text("Start a Tab")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
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
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.08), radius: 10)
        )
        .padding(.horizontal)
    }

    var tabsTimeline: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredTabs) { $tab in
                NavigationLink(value: tab.id) {
                    TabCardView(tab: $tab)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }

            if selectedSection == .active {
                Button {
                    draft.reset()
                    path.append("create")
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Another Tab")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
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
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                }
                .padding(.horizontal)
            }
        }
    }
}
