//
//  AdaptiveLayout.swift
//  Tab
//

import SwiftUI

struct AdaptiveContainerModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    func body(content: Content) -> some View {
        content
            .frame(
                maxWidth: horizontalSizeClass == .regular ? 800 : .infinity
            )
            .frame(maxWidth: .infinity)
    }
}

extension View {
    func adaptiveContainer() -> some View {
        modifier(AdaptiveContainerModifier())
    }
}
