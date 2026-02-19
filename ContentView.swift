import SwiftUI

struct ContentView: View {
    @StateObject private var tabManager = TabManager()
    @State private var path = NavigationPath()

    // Global toast state
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                IntroView(path: $path)

                    .navigationDestination(for: String.self) { route in
                        switch route {
                        case "home":
                            HomeView(path: $path)
                                .environmentObject(tabManager)

                        case "create":
                            CreateOutingView(path: $path)
                                .environmentObject(tabManager)

                        default:
                            EmptyView()
                        }
                    }

                    .navigationDestination(for: UUID.self) { tabID in
                        TabDetailView(tabID: tabID, path: $path)
                            .environmentObject(tabManager)
                    }

                    .navigationDestination(for: EditTabPath.self) { editPath in
                        if let index = tabManager.tabs.firstIndex(where: { $0.id == editPath.tabID }) {
                            EditTabView(
                                tab: $tabManager.tabs[index],
                                path: $path,
                                showToast: $showToast,
                                toastMessage: $toastMessage
                            )
                            .environmentObject(tabManager)
                        } else {
                            Text("Tab not found")
                        }
                    }
            }
            .environmentObject(tabManager)

            // MARK: - GLOBAL TOAST OVERLAY
            VStack {
                if showToast {
                    Text(toastMessage)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                        .padding(.top, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(100)
                }
                Spacer()
            }
            .allowsHitTesting(false)
            .animation(.spring(), value: showToast)
        }
    }
}
