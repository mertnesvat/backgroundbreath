import SwiftUI

@main
struct BreathOverlayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No window scenes — AppDelegate owns all windows
        Settings { EmptyView() }
    }
}
