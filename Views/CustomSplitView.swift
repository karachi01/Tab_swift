//
//  CustomSplitView.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/24/26.
//
import SwiftUI

struct CustomSplitView: View {
    @Binding var friends: [Friend]
    let totalBill: Double   // This already includes tax & tip from previous screen
    let onConfirm: () -> Void

    @FocusState private var isKeyboardFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // MARK: Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Split / Tip")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Each person can enter what they paid and their own tip.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // MARK: Paid + Tip Inputs
                VStack(alignment: .leading, spacing: 16) {
                    Text("Who paid & tipped?")
                        .font(.headline)

                    VStack(spacing: 12) {
                        ForEach($friends) { $friend in
                            VStack(alignment: .leading, spacing: 10) {

                                HStack {
                                    Text(friend.isYou ? "You" : friend.name)
                                        .fontWeight(.medium)
                                    Spacer()
                                }

                                HStack {
                                    Text("Paid")
                                    Spacer()
                                    TextField("0.00", value: $friend.paidAmount, format: .number)
                                        .keyboardType(.decimalPad)
                                        .frame(width: 110)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .focused($isKeyboardFocused)
                                }

                                HStack {
                                    Text("Tip")
                                    Spacer()
                                    TextField("0.00", value: $friend.customTip, format: .number)
                                        .keyboardType(.decimalPad)
                                        .frame(width: 110)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .focused($isKeyboardFocused)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal)

                // MARK: Summary
                VStack(alignment: .leading, spacing: 14) {
                    Text("Summary")
                        .font(.headline)

                    VStack(spacing: 10) {
                        ForEach(friends) { friend in
                            SummaryRow(friend: friend, fairShare: fairShare)
                        }
                    }

                    Divider()

                    HStack {
                        Text("Total Bill")
                        Spacer()
                        Text("$\(totalBill, specifier: "%.2f")")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)

                // MARK: Confirm
                Button {
                    calculateOwes()
                    onConfirm()
                } label: {
                    Text("Confirm Custom Split")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(18)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Custom Split")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture { isKeyboardFocused = false }
        .onAppear { calculateOwes() }
        .onChange(of: friends) { _ in
            calculateOwes()
        }
    }

    // MARK: Logic (FIXED)

    private var fairShare: Double {
        friends.isEmpty ? 0 : totalBill / Double(friends.count)
    }

    private func calculateOwes() {
        for i in friends.indices {
            let contributed = friends[i].paidAmount + friends[i].customTip
            let net = contributed - fairShare

            // owesAmount should represent how much this person still owes
            friends[i].owesAmount = max(-net, 0)
        }
    }
}

struct SummaryRow: View {
    let friend: Friend
    let fairShare: Double

    private var net: Double {
        (friend.paidAmount + friend.customTip) - fairShare
    }

    private var displayText: String {
        if abs(net) < 0.01 {
            return "Settled"
        } else if net > 0 {
            return "+$\(String(format: "%.2f", net))"
        } else {
            return "-$\(String(format: "%.2f", abs(net)))"
        }
    }

    private var displayColor: Color {
        if abs(net) < 0.01 {
            return .secondary
        } else if net > 0 {
            return .green
        } else {
            return .red
        }
    }

    var body: some View {
        HStack {
            Text(friend.isYou ? "You" : friend.name)
                .fontWeight(.medium)
            Spacer()
            Text(displayText)
                .fontWeight(.semibold)
                .foregroundStyle(displayColor)
        }
    }
}
