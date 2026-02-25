//
//  CustomSplitView.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/24/26.
//

import SwiftUI

struct CustomSplitView: View {
    @Binding var friends: [Friend]
    let initialTotal: Double
    let onConfirm: (Double) -> Void

    @State private var sharedTax: String = ""

    @FocusState private var isKeyboardFocused: Bool

    private var taxPerPerson: Double {
        let tax = Double(sharedTax) ?? 0
        guard friends.count > 0 else { return 0 }
        return tax / Double(friends.count)
    }

    private func subtotal(for friend: Friend) -> Double {
        friend.paidAmount + friend.customTip + taxPerPerson
    }

    private var customTotal: Double {
        friends.reduce(0) { $0 + subtotal(for: $1) }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Split / Tip")
                            .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                            .foregroundStyle(Color(.label))

                        Text("Enter each person's amount and tip. Add a shared tax to split it equally.")
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .padding(.horizontal)

                    // MARK: Per-Person Inputs
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Individual Amounts")
                            .font(.headline)
                            .foregroundStyle(Color(.label))
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            ForEach($friends) { $friend in
                                VStack(alignment: .leading, spacing: 10) {

                                    Text(friend.isYou ? "You" : friend.name)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color(.label))

                                    HStack {
                                        Text("Amount")
                                            .foregroundStyle(Color(.secondaryLabel))
                                        Spacer()
                                        Text("$")
                                            .foregroundStyle(Color(.secondaryLabel))
                                        TextField("0.00", value: $friend.paidAmount, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                            .foregroundStyle(Color(.label))
                                            .frame(width: 100)
                                            .padding(8)
                                            .background(Color(.tertiarySystemBackground))
                                            .cornerRadius(10)
                                            .focused($isKeyboardFocused)
                                    }

                                    HStack {
                                        Text("Tip")
                                            .foregroundStyle(Color(.secondaryLabel))
                                        Spacer()
                                        Text("$")
                                            .foregroundStyle(Color(.secondaryLabel))
                                        TextField("0.00", value: $friend.customTip, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                            .foregroundStyle(Color(.label))
                                            .frame(width: 100)
                                            .padding(8)
                                            .background(Color(.tertiarySystemBackground))
                                            .cornerRadius(10)
                                            .focused($isKeyboardFocused)
                                    }

                                    HStack {
                                        Text("Subtotal")
                                            .font(.caption)
                                            .foregroundStyle(Color(.secondaryLabel))
                                        Spacer()
                                        Text("$\(String(format: "%.2f", friend.paidAmount + friend.customTip))")
                                            .font(.caption)
                                            .foregroundStyle(Color(.secondaryLabel))
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(.secondarySystemBackground))
                                        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: Shared Tax
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Shared Tax (Optional)")
                            .font(.headline)
                            .foregroundStyle(Color(.label))

                        Text("Enter the bill's total tax — it will be split equally among everyone.")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))

                        HStack {
                            Text("$")
                                .foregroundStyle(Color(.secondaryLabel))
                            TextField("0.00", text: $sharedTax)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(Color(.label))
                                .focused($isKeyboardFocused)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
                        )

                        if (Double(sharedTax) ?? 0) > 0 {
                            Text("Each person's tax share: $\(String(format: "%.2f", taxPerPerson))")
                                .font(.caption)
                                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))
                        }
                    }
                    .padding(.horizontal)

                    // MARK: Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Summary")
                            .font(.headline)
                            .foregroundStyle(Color(.label))

                        VStack(spacing: 8) {
                            ForEach(friends) { friend in
                                HStack {
                                    Text(friend.isYou ? "You" : friend.name)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color(.label))
                                    Spacer()
                                    Text("$\(String(format: "%.2f", subtotal(for: friend)))")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color(.label))
                                }
                                Divider()
                            }
                        }

                        HStack {
                            Text("Total")
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Text("$\(String(format: "%.2f", customTotal))")
                                .fontWeight(.bold)
                                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
                    )
                    .padding(.horizontal)

                    // MARK: Confirm
                    Button {
                        isKeyboardFocused = false
                        for i in friends.indices {
                            friends[i].owesAmount = subtotal(for: friends[i])
                        }
                        onConfirm(customTotal)
                    } label: {
                        Text("Confirm Custom Split")
                            .font(.system(.headline, design: .rounded))
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
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Custom Split")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture { isKeyboardFocused = false }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isKeyboardFocused = false }
            }
        }
    }
}
