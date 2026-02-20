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

    // Each person's equal share of the shared tax
    private var taxPerPerson: Double {
        let tax = Double(sharedTax) ?? 0
        guard friends.count > 0 else { return 0 }
        return tax / Double(friends.count)
    }

    // Individual total: amount + tip + their tax share
    private func subtotal(for friend: Friend) -> Double {
        friend.paidAmount + friend.customTip + taxPerPerson
    }

    // Grand total across everyone
    private var customTotal: Double {
        friends.reduce(0) { $0 + subtotal(for: $1) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // MARK: Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Split / Tip")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 30/255, green: 60/255, blue: 55/255))

                    Text("Enter each person's amount and tip. Add a shared tax to split it equally.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 90/255, green: 120/255, blue: 110/255))
                }
                .padding(.horizontal)

                // MARK: Per-Person Inputs
                VStack(alignment: .leading, spacing: 16) {
                    Text("Individual Amounts")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        ForEach($friends) { $friend in
                            VStack(alignment: .leading, spacing: 10) {

                                Text(friend.isYou ? "You" : friend.name)
                                    .fontWeight(.semibold)

                                HStack {
                                    Text("Amount")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("$")
                                        .foregroundStyle(.secondary)
                                    TextField("0.00", value: $friend.paidAmount, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 100)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .focused($isKeyboardFocused)
                                }

                                HStack {
                                    Text("Tip")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("$")
                                        .foregroundStyle(.secondary)
                                    TextField("0.00", value: $friend.customTip, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 100)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .focused($isKeyboardFocused)
                                }

                                // Subtotal before shared tax
                                HStack {
                                    Text("Subtotal")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", friend.paidAmount + friend.customTip))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.95))
                                    .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                // MARK: Shared Tax
                VStack(alignment: .leading, spacing: 10) {
                    Text("Shared Tax (Optional)")
                        .font(.headline)

                    Text("Enter the bill's total tax — it will be split equally among everyone.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $sharedTax)
                            .keyboardType(.decimalPad)
                            .focused($isKeyboardFocused)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.95))
                            .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
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

                    VStack(spacing: 8) {
                        ForEach(friends) { friend in
                            HStack {
                                Text(friend.isYou ? "You" : friend.name)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("$\(String(format: "%.2f", subtotal(for: friend)))")
                                    .fontWeight(.semibold)
                            }
                            Divider()
                        }
                    }

                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
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
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
                )
                .padding(.horizontal)

                // MARK: Confirm
                Button {
                    isKeyboardFocused = false
                    // Store each person's individual total for record-keeping
                    for i in friends.indices {
                        friends[i].owesAmount = subtotal(for: friends[i])
                    }
                    onConfirm(customTotal)
                } label: {
                    Text("Confirm Custom Split")
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
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Custom Split")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture { isKeyboardFocused = false }
    }
}
