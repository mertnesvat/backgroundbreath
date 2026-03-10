import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var panel: FloatingPanel!
    private let breathTimer = BreathTimer()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupPanel()
        setupMenuBar()
        breathTimer.start()
    }

    private func setupPanel() {
        let size = NSSize(width: 88, height: 100)
        // Default position: bottom-right of main screen
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let origin = NSPoint(x: screen.maxX - size.width - 40, y: screen.minY + 40)
        panel = FloatingPanel(contentRect: NSRect(origin: origin, size: size))

        let view = BreathAnimationView(timer: breathTimer)
        panel.contentView = NSHostingView(rootView: view)
        panel.alphaValue = 0.15
        panel.orderFrontRegardless()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        updateMenuBarIcon()
        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()
        let toggleItem = NSMenuItem(
            title: breathTimer.isRunning ? "Pause" : "Start",
            action: #selector(toggleBreath),
            keyEquivalent: ""
        )
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc private func toggleBreath() {
        breathTimer.toggle()
        buildMenu()  // refresh Start/Pause label
        updateMenuBarIcon()
    }

    private func updateMenuBarIcon() {
        // Warm circle SF Symbol or simple button
        statusItem.button?.title = "◉"
    }
}
