//
//  HomeView.swift
//  Tab
//

import SwiftUI

enum HomeTabSection: Hashable {
    case active
    case settled
}

enum HomeDisplayMode {
    case list
    case monthly
    case yearly
}

struct HomeBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if colorScheme == .dark {
            Color(.secondarySystemBackground)
        } else {
            Color.white
                .overlay(
                    LinearGradient(
                        colors: [
                            Color(red: 241 / 255, green: 239 / 255, blue: 228 / 255).opacity(0.15),
                            Color(red: 230 / 255, green: 238 / 255, blue: 235 / 255).opacity(0.1),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var draft: OutingDraft
    @Binding var path: NavigationPath

    @State private var selectedSection: HomeTabSection = .active
    @State private var displayMode: HomeDisplayMode = .list
    @State private var expandedMonths: Set<String> = []
    @State private var expandedYears: Set<String> = []

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView(selection: $selectedSection) {
            SwiftUI.Tab("Your Tabs", systemImage: "list.bullet", value: .active) {
                sectionContent(for: .active)
            }

            SwiftUI.Tab("Settled", systemImage: "checkmark.circle", value: .settled) {
                sectionContent(for: .settled)
            }
        }
        .tint(Color(red: 70 / 255, green: 140 / 255, blue: 125 / 255))
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}



extension HomeView {

    @ViewBuilder
    fileprivate func sectionContent(for section: HomeTabSection) -> some View {
        ZStack(alignment: .bottomTrailing) {
            HomeBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    sectionHeader(for: section)
                    viewToggle

                    let tabs = filteredTabs(for: section)
                    if tabs.isEmpty {
                        emptyState(for: section)
                    } else {
                        if displayMode == .list {
                            tabsTimeline(for: section)
                        } else if displayMode == .monthly {
                            monthlyFolders(for: section)
                        } else {
                            yearlyFolders(for: section)
                        }
                    }
                }
                .padding(.top)
            }

            if section == .active {
                fabButton
                    .padding(.trailing, 24)
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }



    fileprivate func filteredTabs(for section: HomeTabSection) -> [Binding<Tab>] {
        switch section {
        case .active:
            return $tabManager.tabs.filter { !$0.wrappedValue.isSettled }
        case .settled:
            return $tabManager.tabs.filter { $0.wrappedValue.isSettled }
        }
    }



    fileprivate func sectionHeader(for section: HomeTabSection) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(section == .active ? "Your Tabs" : "Settled Tabs")
                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color(.label)
                        : Color(red: 30 / 255, green: 60 / 255, blue: 55 / 255)
                )

            Text(
                section == .active
                    ? "Shared moments, settled gently."
                    : "Memories already taken care of."
            )
            .font(.system(.body, design: .rounded, weight: .medium))
            .foregroundStyle(
                colorScheme == .dark
                    ? Color(.label)
                    : Color(red: 30 / 255, green: 60 / 255, blue: 55 / 255)
            )
        }
        .padding(.horizontal)
    }



    fileprivate var viewToggle: some View {
        HStack {
            ForEach([("List", HomeDisplayMode.list),
                     ("Monthly", HomeDisplayMode.monthly),
                     ("Yearly", HomeDisplayMode.yearly)], id: \.0) { label, mode in
                Button {
                    displayMode = mode
                } label: {
                    Text(label)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(
                            colorScheme == .dark
                                ? Color(.label)
                                : Color(red: 30 / 255, green: 60 / 255, blue: 55 / 255)
                        )
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .background(displayMode == mode ? Color.green.opacity(0.2) : Color.clear)
                        .cornerRadius(20)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }



    fileprivate func monthlyFolders(for section: HomeTabSection) -> some View {
        let tabs = filteredTabs(for: section)
        let grouped = Dictionary(grouping: tabs) {
            monthString(from: $0.wrappedValue.date)
        }
        let sortedKeys = grouped.keys.sorted {
            monthDate(from: $0) > monthDate(from: $1)
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
                                .foregroundStyle(Color(.label))
                            Text(month)
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Text("\(tabsForMonth.count) tab\(tabsForMonth.count == 1 ? "" : "s")")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(Color(.secondaryLabel))
                            Image(systemName: expandedMonths.contains(month) ? "chevron.down" : "chevron.right")
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.06), radius: 6)
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

 

    fileprivate func yearlyFolders(for section: HomeTabSection) -> some View {
        let tabs = filteredTabs(for: section)
        let grouped = Dictionary(grouping: tabs) {
            yearString(from: $0.wrappedValue.date)
        }
        let sortedKeys = grouped.keys.sorted { $0 > $1 }

        return LazyVStack(spacing: 14) {
            ForEach(sortedKeys, id: \.self) { year in
                let tabsForYear = grouped[year] ?? []

                VStack(alignment: .leading, spacing: 8) {

                    Button {
                        if expandedYears.contains(year) {
                            expandedYears.remove(year)
                        } else {
                            expandedYears.insert(year)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))
                            Text(year)
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Text("\(tabsForYear.count) tab\(tabsForYear.count == 1 ? "" : "s")")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(Color(.secondaryLabel))
                            Image(systemName: expandedYears.contains(year) ? "chevron.down" : "chevron.right")
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.06), radius: 6)
                        )
                    }
                    .buttonStyle(.plain)

                    if expandedYears.contains(year) {
                        let monthGrouped = Dictionary(grouping: tabsForYear) {
                            monthString(from: $0.wrappedValue.date)
                        }
                        let sortedMonths = monthGrouped.keys.sorted {
                            monthDate(from: $0) > monthDate(from: $1)
                        }

                        LazyVStack(spacing: 10) {
                            ForEach(sortedMonths, id: \.self) { month in
                                let tabsForMonth = monthGrouped[month] ?? []

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
                                                .font(.system(.subheadline))
                                                .foregroundStyle(Color(.secondaryLabel))
                                            Text(month)
                                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                                .foregroundStyle(Color(.label))
                                            Spacer()
                                            Text("\(tabsForMonth.count) tab\(tabsForMonth.count == 1 ? "" : "s")")
                                                .font(.system(.caption, design: .rounded, weight: .medium))
                                                .foregroundStyle(Color(.secondaryLabel))
                                            Image(systemName: expandedMonths.contains(month) ? "chevron.down" : "chevron.right")
                                                .font(.system(.caption))
                                                .foregroundStyle(Color(.secondaryLabel))
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(Color(.secondarySystemBackground))
                                                .shadow(color: .black.opacity(0.04), radius: 4)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.leading, 16)

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
                            }
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding(.horizontal)
            }
        }
    }



    fileprivate func monthString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    fileprivate func monthDate(from string: String) -> Date {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.date(from: string) ?? Date()
    }

    fileprivate func yearString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f.string(from: date)
    }



    fileprivate func emptyState(for section: HomeTabSection) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color(red: 40 / 255, green: 90 / 255, blue: 80 / 255))

            Text("No tabs here")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(Color(.label))

            Text(
                section == .active
                    ? "Start a tab with friends to see it here."
                    : "Tabs you settle will appear here."
            )
            .font(.system(.body, design: .rounded, weight: .medium))
            .foregroundStyle(Color(.secondaryLabel))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .lineSpacing(4)

            if section == .active {
                Button {
                    draft.reset()
                    path.append("create")
                } label: {
                    Text("Start a Tab")
                        .font(.system(.headline, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 70 / 255, green: 140 / 255, blue: 125 / 255),
                                    Color(red: 110 / 255, green: 180 / 255, blue: 160 / 255),
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
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 10)
        )
        .padding(.horizontal)
    }



    fileprivate func tabsTimeline(for section: HomeTabSection) -> some View {
        let tabs = filteredTabs(for: section)
        return LazyVStack(spacing: 16) {
            ForEach(tabs) { $tab in
                NavigationLink(value: tab.id) {
                    TabCardView(tab: $tab)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }

            if section == .active {
                Button {
                    draft.reset()
                    path.append("create")
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Another Tab")
                            .font(.system(.headline, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 70 / 255, green: 140 / 255, blue: 125 / 255),
                                Color(red: 110 / 255, green: 180 / 255, blue: 160 / 255),
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



    fileprivate var fabButton: some View {
        Button {
            draft.reset()
            path.append("create")
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 70 / 255, green: 140 / 255, blue: 125 / 255),
                                Color(red: 110 / 255, green: 180 / 255, blue: 160 / 255),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.15), radius: 6, y: 3)

                Image(systemName: "plus")
                    .font(.system(.title, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
