//
//  WhoPaidView.swift
//  Tab
//

import SwiftUI
import CoreLocation

enum WhoPaidField {
    case totalBill, tax, tip
}

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

    @FocusState private var focusedField: WhoPaidField?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

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

            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Bill Split")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture { focusedField = nil }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .onAppear {
            if friends.isEmpty { friends = draft.friends }
        }
        .navigationDestination(isPresented: $showCustomSplit) {
            CustomSplitView(
                friends: $friends,
                initialTotal: totalWithTaxAndTip
            ) { customTotal in
                saveTab(total: customTotal)
            }
        }
    }


    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Who Paid?")
                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                .foregroundStyle(colorScheme == .dark ? Color.white : Color(red: 30/255, green: 60/255, blue: 55/255))

            Text("Enter the bill details and select who paid.")
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.7) : Color(red: 90/255, green: 120/255, blue: 110/255))
        }
        .padding(.horizontal)
    }


    private var billInputSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Total Bill")
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
                HStack {
                    Text("$").foregroundStyle(Color(.secondaryLabel))
                    TextField("0.00", text: $totalBill)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .totalBill)
                        .foregroundStyle(Color(.label))
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
                )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Tax (optional)")
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
                HStack {
                    Text("$").foregroundStyle(Color(.secondaryLabel))
                    TextField("0.00", text: $taxAmount)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .tax)
                        .foregroundStyle(Color(.label))
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
                )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Tip")
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
                HStack {
                    TextField("0.00", text: $tipPercentage)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .tip)
                        .foregroundStyle(Color(.label))
                    Text("%").foregroundStyle(Color(.secondaryLabel))
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
                )
            }
        }
        .padding(.horizontal)
    }


    private var whoPaidSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who Paid?")
                .font(.headline)
                .foregroundStyle(Color(.label))

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(friends) { friend in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(friend.isYou ? "You" : friend.name)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(.label))
                                if friend.isYou {
                                    Text("That's you")
                                        .font(.caption)
                                        .foregroundStyle(Color(.secondaryLabel))
                                }
                            }
                            Spacer()
                            Image(systemName: payerID == friend.id ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))
                                .font(.system(.title2))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            payerID = friend.id
                            focusedField = nil
                        }
                        Divider()
                    }
                }
            }
            .frame(maxHeight: 220)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
            )
        }
        .padding(.horizontal)
    }


    private var splitButtonsSection: some View {
        VStack(spacing: 12) {
            GradientButton(title: "Split Equally") {
                focusedField = nil
                splitBill()
            }
            GradientButton(title: "Custom Split/Tip", icon: "chevron.right") {
                focusedField = nil
                showCustomSplit = true
            }
        }
        .padding(.horizontal)
    }


    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
                .foregroundStyle(Color(.label))

            HStack {
                Text("Total (with tax & tip)")
                    .foregroundStyle(Color(.secondaryLabel))
                Spacer()
                Text("$\(totalWithTaxAndTip, specifier: "%.2f")")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.label))
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(friends) { friend in
                        Text("\(friend.isYou ? "You" : friend.name) owes $\(String(format: "%.2f", friend.owesAmount))")
                            .foregroundStyle(Color(.secondaryLabel))
                        Divider()
                    }
                }
            }
            .frame(maxHeight: 150)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
            )
        }
        .padding(.horizontal)
    }


    private var confirmButton: some View {
        Button {
            focusedField = nil
            confirmAndSave()
        } label: {
            Text("Confirm & Save")
                .font(.system(.headline, design: .rounded))
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
            friends[i].paidAmount = friends[i].id == payerID ? total : 0
        }
    }

    private func confirmAndSave() {
        guard canConfirm else { return }
        saveTab(total: totalWithTaxAndTip)
    }

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


struct BillInputField: View {
    let title: String
    @Binding var text: String
    var suffix: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color(.secondaryLabel))
            HStack {
                if title.lowercased().contains("bill") || title.lowercased().contains("tax") {
                    Text("$").foregroundStyle(Color(.secondaryLabel))
                }
                TextField("0.00", text: $text)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(Color(.label))
                if let suffix = suffix {
                    Text(suffix).foregroundStyle(Color(.secondaryLabel))
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
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
            .font(.system(.headline, design: .rounded))
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
