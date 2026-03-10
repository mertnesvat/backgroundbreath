import AppKit

final class FloatingPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        level = .floating
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false  // keep false — drag handled by isMovableByWindowBackground
        collectionBehavior = [.canJoinAllSpaces, .stationary]
        isMovableByWindowBackground = true
    }
}
