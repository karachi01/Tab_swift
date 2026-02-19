//
//  CustomSplitView.swift
//  Tab
//
//  Created by Karachi Onwuanibe on 1/24/26.
//

import SwiftUI

struct CustomSplitView: View {
    @Binding var friends: [Friend]
    let totalBill: Double   // Already includes tax & tip from previous screen
    let onConfirm: () -> Void

    @FocusState private var isKeyboardFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // MARK: Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Split / Tip")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 30/255, green: 60/255, blue: 55/255))

                    Text("Each person can enter what they paid and their own tip.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 90/255, green: 120/255, blue: 110/255))
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
                                    .fill(Color.white.opacity(0.95))
                                    .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
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
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
                )
                .padding(.horizontal)

                // MARK: Confirm
                Button {
                    calculateOwes()
                    onConfirm()
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
        .onAppear { calculateOwes() }
        .onChange(of: friends) { _ in
            calculateOwes()
        }
    }

    // MARK: Logic

    private var fairShare: Double {
        friends.isEmpty ? 0 : totalBill / Double(friends.count)
    }

    private func calculateOwes() {
        for i in friends.indices {
            let contributed = friends[i].paidAmount + friends[i].customTip
            let net = contributed - fairShare
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
