//
//  WhoPaidView.swift
//  Tab
//

import SwiftUI
import CoreLocation

struct WhoPaidView: View {
    @EnvironmentObject var draft: OutingDraft
    @EnvironmentObject var tabManager: TabManager
    @Binding var path: NavigationPath

    @State private var friends: [Friend] = []
    @State private var totalBill: String = ""
    @State private var payerID: UUID?
    @State private var showCustomSplit = false
    @State private var taxAmount: String = ""
    @State private var tipPercentage: String = ""

    @FocusState private var isKeyboardFocused: Bool

    var body: some View {
        ZStack {
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

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    headerSection
                    billInputSection
                    whoPaidSection
                    splitButtonsSection
                    summarySection
                    confirmButton
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Bill Split")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture { isKeyboardFocused = false }
        .onAppear {
            if friends.isEmpty {
                friends = draft.friends
            }
        }
        .navigationDestination(isPresented: $showCustomSplit) {
            CustomSplitView(
                friends: $friends,
                initialTotal: totalWithTaxAndTip
            ) { customTotal in
                // Coming from CustomSplitView — bypass the WhoPaidView guards
                // and save directly with the custom total.
                saveTab(total: customTotal)
            }
        }
    }

    // MARK: Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Who Paid?")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 30/255, green: 60/255, blue: 55/255))

            Text("Enter the bill details and select who paid.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 90/255, green: 120/255, blue: 110/255))
        }
        .padding(.horizontal)
    }

    // MARK: Bill Inputs
    private var billInputSection: some View {
        VStack(spacing: 16) {
            BillInputField(title: "Total Bill", text: $totalBill, isKeyboardFocused: _isKeyboardFocused)
            BillInputField(title: "Tax (optional)", text: $taxAmount, isKeyboardFocused: _isKeyboardFocused)
            BillInputField(title: "Tip", text: $tipPercentage, suffix: "%", isKeyboardFocused: _isKeyboardFocused)
        }
        .padding(.horizontal)
    }

    // MARK: Who Paid Section
    private var whoPaidSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who Paid?")
                .font(.headline)

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(friends) { friend in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(friend.isYou ? "You" : friend.name)
                                    .fontWeight(.medium)
                                if friend.isYou {
                                    Text("That's you")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Image(systemName: payerID == friend.id ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))
                                .font(.system(size: 22))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            payerID = friend.id
                            isKeyboardFocused = false
                        }

                        Divider()
                    }
                }
            }
            .frame(maxHeight: 220)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
            )
        }
        .padding(.horizontal)
    }

    // MARK: Split Buttons Section
    private var splitButtonsSection: some View {
        VStack(spacing: 12) {
            GradientButton(title: "Split Equally") {
                isKeyboardFocused = false
                splitBill()
            }

            GradientButton(title: "Custom Split/Tip", icon: "chevron.right") {
                isKeyboardFocused = false
                showCustomSplit = true
            }
        }
        .padding(.horizontal)
    }

    // MARK: Summary Section
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)

            HStack {
                Text("Total (with tax & tip)")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("$\(totalWithTaxAndTip, specifier: "%.2f")")
                    .fontWeight(.semibold)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(friends) { friend in
                        Text("\(friend.isYou ? "You" : friend.name) owes $\(String(format: "%.2f", friend.owesAmount))")
                            .foregroundStyle(.secondary)

                        Divider()
                    }
                }
            }
            .frame(maxHeight: 150)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
            )
        }
        .padding(.horizontal)
    }

    // MARK: Confirm Button
    // Only shown / enabled when the user fills in WhoPaidView fields directly.
    private var confirmButton: some View {
        Button {
            isKeyboardFocused = false
            confirmAndSave()
        } label: {
            Text("Confirm & Save")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    ZStack {
                        if canConfirm {
                            LinearGradient(
                                colors: [Color(red: 70/255, green: 140/255, blue: 125/255),
                                         Color(red: 110/255, green: 180/255, blue: 160/255)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.gray.opacity(0.4)
                        }
                    }
                )
                .foregroundStyle(.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
        }
        .disabled(!canConfirm)
        .padding(.horizontal)
    }

    // MARK: Helpers

    /// Enabled only when the user has filled in WhoPaidView directly.
    private var canConfirm: Bool {
        Double(totalBill) != nil && payerID != nil
    }

    private var totalWithTaxAndTip: Double {
        let bill = Double(totalBill) ?? 0
        let tax = Double(taxAmount) ?? 0
        let tip = Double(tipPercentage) ?? 0
        return bill + tax + (bill * tip / 100)
    }

    private func splitBill() {
        let total = totalWithTaxAndTip
        guard total > 0 else { return }

        let splitAmount = total / Double(friends.count)
        for i in friends.indices {
            friends[i].owesAmount = friends[i].id == payerID ? 0 : splitAmount
        }
    }

    /// Called by the "Confirm & Save" button — requires WhoPaidView fields to be filled.
    private func confirmAndSave() {
        guard canConfirm else { return }
        saveTab(total: totalWithTaxAndTip)
    }

    /// Core save logic — no guards on WhoPaidView fields so CustomSplitView
    /// can call this directly with its own total, even if totalBill / payerID
    /// were never set on this screen.
    private func saveTab(total: Double) {
        guard total > 0 else { return }

        let tab = Tab(
            restaurantName: draft.locationName.isEmpty ? "Group Outing" : draft.locationName,
            date: draft.outingDate,
            totalAmount: total,
            friends: friends,
            imageData: draft.selectedImage?.jpegData(compressionQuality: 0.8),
            iconName: draft.selectedIcon
        )

        tabManager.tabs.append(tab)
        draft.reset()

        showCustomSplit = false

        var newPath = NavigationPath()
        newPath.append("home")
        path = newPath
    }
}

// MARK: - Reusable Components
struct BillInputField: View {
    let title: String
    @Binding var text: String
    var suffix: String? = nil
    @FocusState var isKeyboardFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                if title.lowercased().contains("bill") || title.lowercased().contains("tax") {
                    Text("$").foregroundStyle(.secondary)
                }

                TextField("0.00", text: $text)
                    .keyboardType(.decimalPad)
                    .focused($isKeyboardFocused)

                if let suffix = suffix {
                    Text(suffix).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
            )
        }
    }
}

struct GradientButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if let icon = icon { Spacer(); Image(systemName: icon) }
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color(red: 70/255, green: 140/255, blue: 125/255),
                             Color(red: 110/255, green: 180/255, blue: 160/255)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
        }
    }
}
