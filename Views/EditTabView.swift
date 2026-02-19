//
//  EditTabView.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/12/26.
//
//
import SwiftUI

struct EditTabView: View {
    @Binding var tab: Tab
    @EnvironmentObject var tabManager: TabManager
    @Binding var path: NavigationPath

    @State private var totalBill: String = ""
    @State private var taxAmount: String = ""
    @State private var tipPercentage: String = ""
    @State private var payerID: UUID? = nil
    @State private var showCustomSplit = false

    @FocusState private var isKeyboardFocused: Bool

    @Binding var showToast: Bool
    @Binding var toastMessage: String

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {

                // MARK: Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Edit Tab")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Edit the bill details and who paid.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // MARK: Bill Inputs
                VStack(spacing: 16) {

                    billField(title: "Total Bill", text: $totalBill, prefix: "$")
                    billField(title: "Tax (optional)", text: $taxAmount, prefix: "$")
                    billField(title: "Tip", text: $tipPercentage, suffix: "%")
                }
                .padding(.horizontal)

                // MARK: Who Paid
                VStack(alignment: .leading, spacing: 12) {
                    Text("Who Paid?")
                        .font(.headline)

                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(tab.friends) { friend in
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

                                    Image(systemName: payerID == friend.id
                                          ? "checkmark.circle.fill"
                                          : "circle")
                                        .foregroundStyle(.blue)
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
                }
                .padding(.horizontal)

                // MARK: Split Options
                VStack(spacing: 12) {
                    Button {
                        isKeyboardFocused = false
                        splitBill()
                    } label: {
                        Text("Split Equally")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .cornerRadius(14)
                    }

                    Button {
                        isKeyboardFocused = false
                        showCustomSplit = true
                    } label: {
                        HStack {
                            Text("Custom Split")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal)

                // MARK: Summary
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
                            ForEach(tab.friends) { friend in
                                Text(
                                    "\(friend.isYou ? "You" : friend.name) owes $\(String(format: "%.2f", friend.owesAmount))"
                                )
                                .foregroundStyle(.secondary)

                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                }
                .padding(.horizontal)

                // MARK: Save
                Button {
                    isKeyboardFocused = false
                    saveEdits()
                } label: {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canConfirm ? Color.blue : Color.gray.opacity(0.4))
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                }
                .disabled(!canConfirm)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Edit Tab")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture { isKeyboardFocused = false }
        .onAppear {
            totalBill = String(format: "%.2f", tab.totalAmount)
            payerID = tab.friends.first(where: { $0.paidAmount > 0 })?.id
        }
        .navigationDestination(isPresented: $showCustomSplit) {
            CustomSplitView(
                friends: $tab.friends,
                totalBill: totalWithTaxAndTip
            ) {
                saveEdits()
            }
        }
    }

    // MARK: Helpers

    private func billField(title: String, text: Binding<String>, prefix: String? = nil, suffix: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                if let prefix { Text(prefix).foregroundStyle(.secondary) }
                TextField("0.00", text: text)
                    .keyboardType(.decimalPad)
                    .focused($isKeyboardFocused)
                if let suffix { Text(suffix).foregroundStyle(.secondary) }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.3))
            )
        }
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

        let splitAmount = total / Double(tab.friends.count)
        for i in tab.friends.indices {
            tab.friends[i].owesAmount = tab.friends[i].id == payerID ? 0 : splitAmount
        }
    }

    private func saveEdits() {
        tab.totalAmount = totalWithTaxAndTip
        tabManager.update(tab: tab)

        toastMessage = "Changes saved"
        withAnimation { showToast = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showToast = false }
            path.removeLast()
        }
    }
}
