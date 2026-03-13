import AppKit
import SwiftUI
import Combine
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var panel: FloatingPanel!
    private let breathTimer = BreathTimer()
    let breathSettings = BreathSettings()
    private var settingsWindow: NSWindow?
    private var aboutWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupPanel()
        setupMenuBar()

        if let p = BreathPattern.all.first(where: { $0.id == breathSettings.selectedPatternId }) {
            breathTimer.setPattern(p)
        }
        breathTimer.start()

        // Enable launch at login by default on first run
        if !UserDefaults.standard.bool(forKey: "hasConfiguredLaunchAtLogin") {
            try? SMAppService.mainApp.register()
            UserDefaults.standard.set(true, forKey: "hasConfiguredLaunchAtLogin")
        }

        breathSettings.$windowOpacity.sink { [weak self] val in
            self?.panel.alphaValue = val
        }.store(in: &cancellables)

        breathSettings.$orbSize.sink { [weak self] size in
            guard let self, let panel = self.panel else { return }
            let newSize = NSSize(width: size + 28, height: size + 40)
            panel.setContentSize(newSize)
        }.store(in: &cancellables)

        breathSettings.$selectedPatternId.sink { [weak self] id in
            guard let self,
                  let p = BreathPattern.all.first(where: { $0.id == id }) else { return }
            self.breathTimer.setPattern(p)
            self.buildMenu()
        }.store(in: &cancellables)

        breathSettings.$lockPosition.sink { [weak self] locked in
            guard let self else { return }
            self.panel.ignoresMouseEvents = locked
            self.panel.isMovableByWindowBackground = !locked
        }.store(in: &cancellables)
    }

    private func setupPanel() {
        let size = NSSize(width: breathSettings.orbSize + 28, height: breathSettings.orbSize + 40)
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let origin = NSPoint(x: screen.maxX - size.width - 40, y: screen.minY + 40)
        panel = FloatingPanel(contentRect: NSRect(origin: origin, size: size))

        let view = TriangleBreathView(timer: breathTimer, settings: breathSettings)
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

        // Start / Pause
        menu.addItem(NSMenuItem(
            title: breathTimer.isRunning ? "Pause" : "Start",
            action: #selector(toggleBreath),
            keyEquivalent: ""
        ))

        menu.addItem(.separator())

        // Breathing Pattern submenu
        let patternSubmenu = NSMenu()
        for pattern in BreathPattern.all {
            let item = NSMenuItem(title: pattern.name, action: #selector(selectPattern(_:)), keyEquivalent: "")
            item.representedObject = pattern.id
            item.state = pattern.id == breathSettings.selectedPatternId ? .on : .off
            patternSubmenu.addItem(item)
        }
        let patternItem = NSMenuItem(title: "Breathing Pattern", action: nil, keyEquivalent: "")
        patternItem.submenu = patternSubmenu
        menu.addItem(patternItem)

        menu.addItem(.separator())

        // Appearance (orb UI settings)
        menu.addItem(NSMenuItem(title: "Appearance…", action: #selector(openSettings), keyEquivalent: ","))

        // Launch at Login
        let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        loginItem.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(.separator())

        // About
        menu.addItem(NSMenuItem(title: "About BackgroundBreath", action: #selector(openAbout), keyEquivalent: ""))

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc private func toggleBreath() {
        breathTimer.toggle()
        buildMenu()
        updateMenuBarIcon()
    }

    @objc private func selectPattern(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else { return }
        breathSettings.selectedPatternId = id
        // buildMenu() is called via the selectedPatternId sink
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            // silently ignore — user can retry
        }
        buildMenu()
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let view = SettingsView(settings: breathSettings, timer: breathTimer)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 340, height: 580),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Appearance"
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: view)
            window.center()
            settingsWindow = window
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func openAbout() {
        if aboutWindow == nil {
            let view = AboutView(settings: breathSettings)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "About BackgroundBreath"
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: view)
            window.center()
            aboutWindow = window
        }
        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func updateMenuBarIcon() {
        statusItem.button?.image = NSImage(systemSymbolName: "triangle", accessibilityDescription: "BackgroundBreath")
    }
}
