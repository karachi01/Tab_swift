//
//  EditTabView.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/12/26.
//

import SwiftUI

enum EditTabField {
    case totalBill, tax, tip
}

struct EditTabView: View {
    @Binding var tab: Tab
    @EnvironmentObject var tabManager: TabManager
    @Binding var path: NavigationPath

    @State private var totalBill: String = ""
    @State private var taxAmount: String = ""
    @State private var tipPercentage: String = ""
    @State private var payerID: UUID? = nil
    @State private var showCustomSplit = false

    @FocusState private var focusedField: EditTabField?

    @Binding var showToast: Bool
    @Binding var toastMessage: String

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
                    saveButton
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Edit Tab")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture { focusedField = nil }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .onAppear {
            totalBill = String(format: "%.2f", tab.totalAmount)
            payerID = tab.friends.first(where: { $0.paidAmount > 0 })?.id
        }
        .navigationDestination(isPresented: $showCustomSplit) {
            CustomSplitView(
                friends: $tab.friends,
                initialTotal: totalWithTaxAndTip
            ) { customTotal in
                saveEdits(overrideTotal: customTotal)
            }
        }
    }

    // MARK: Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Edit Tab")
                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                .foregroundStyle(Color(.label))

            Text("Edit the bill details and who paid.")
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding(.horizontal)
    }

    // MARK: Bill Inputs
    private var billInputSection: some View {
        VStack(spacing: 16) {

            // Total Bill
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

            // Tax
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

            // Tip
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

    // MARK: Who Paid Section
    private var whoPaidSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who Paid?")
                .font(.headline)
                .foregroundStyle(Color(.label))

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(tab.friends) { friend in
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
                            Image(systemName: payerID == friend.id
                                  ? "checkmark.circle.fill"
                                  : "circle")
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

    // MARK: Split Buttons Section
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

    // MARK: Summary Section
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
                    ForEach(tab.friends) { friend in
                        Text(
                            "\(friend.isYou ? "You" : friend.name) owes $\(String(format: "%.2f", friend.owesAmount))"
                        )
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

    // MARK: Save Button
    private var saveButton: some View {
        Button {
            focusedField = nil
            saveEdits()
        } label: {
            Text("Save Changes")
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

    // MARK: Helpers
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
        let splitAmount = total / Double(tab.friends.count)
        for i in tab.friends.indices {
            tab.friends[i].owesAmount = tab.friends[i].id == payerID ? 0 : splitAmount
        }
    }

    private func saveEdits(overrideTotal: Double? = nil) {
        tab.totalAmount = overrideTotal ?? totalWithTaxAndTip
        tabManager.update(tab: tab)

        toastMessage = "Changes saved"
        withAnimation { showToast = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showToast = false }
            path.removeLast()
        }
    }
}
