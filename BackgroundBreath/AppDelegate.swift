import AppKit
import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var panel: FloatingPanel!
    private let breathTimer = BreathTimer()
    let breathSettings = BreathSettings()
    private var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupPanel()
        setupMenuBar()
        breathTimer.start()

        breathSettings.$windowOpacity.sink { [weak self] val in
            self?.panel.alphaValue = val
        }.store(in: &cancellables)

        breathSettings.$orbSize.sink { [weak self] size in
            guard let self, let panel = self.panel else { return }
            let newSize = NSSize(width: size + 28, height: size + 40)
            panel.setContentSize(newSize)
        }.store(in: &cancellables)
    }

    private func setupPanel() {
        let size = NSSize(width: breathSettings.orbSize + 28, height: breathSettings.orbSize + 40)
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let origin = NSPoint(x: screen.maxX - size.width - 40, y: screen.minY + 40)
        panel = FloatingPanel(contentRect: NSRect(origin: origin, size: size))

        let view = BreathAnimationView(timer: breathTimer, settings: breathSettings)
        panel.contentView = NSHostingView(rootView: view)
        panel.alphaValue = breathSettings.windowOpacity
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
        menu.addItem(NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc private func toggleBreath() {
        breathTimer.toggle()
        buildMenu()
        updateMenuBarIcon()
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let view = SettingsView(settings: breathSettings)
            let contentRect = NSRect(x: 0, y: 0, width: 340, height: 420)
            let window = NSWindow(
                contentRect: contentRect,
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "BackgroundBreath Settings"
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: view)
            window.center()
            settingsWindow = window
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func updateMenuBarIcon() {
        statusItem.button?.title = "◉"
    }
}
