//
//  AdaptiveLayout.swift
//  Tab
//

import SwiftUI

struct AdaptiveContainerModifier<Background: View>: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let background: Background

    init(background: Background) {
        self.background = background
    }

    func body(content: Content) -> some View {
        ZStack {
            background
                .ignoresSafeArea()

            content
                .frame(maxWidth: horizontalSizeClass == .regular ? 800 : .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

extension View {
    func adaptiveContainer() -> some View {
        modifier(AdaptiveContainerModifier(background: EmptyView()))
    }

    func adaptiveContainer<Background: View>(
        @ViewBuilder background: () -> Background
    ) -> some View {
        modifier(AdaptiveContainerModifier(background: background()))
    }
}
