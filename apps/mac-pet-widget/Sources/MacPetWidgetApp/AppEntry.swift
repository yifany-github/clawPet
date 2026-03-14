import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
  private var window: NSWindow?
  private let bridgeStore = BridgeStore()

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.regular)
    createMainWindow()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }

  private func createMainWindow() {
    let contentView = WidgetRootView()
      .environmentObject(bridgeStore)
    let hostingController = NSHostingController(rootView: contentView)

    let window = NSWindow(contentViewController: hostingController)
    window.identifier = NSUserInterfaceItemIdentifier("clawpet-window")
    window.setContentSize(NSSize(width: 456, height: 392))
    window.styleMask = [.borderless]
    window.level = .floating
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    window.backgroundColor = .clear
    window.isOpaque = false
    window.hasShadow = false
    window.isExcludedFromWindowsMenu = true
    window.contentView?.wantsLayer = true
    window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    window.contentViewController?.view.wantsLayer = true
    window.contentViewController?.view.layer?.backgroundColor = NSColor.clear.cgColor
    window.contentView?.superview?.wantsLayer = true
    window.contentView?.superview?.layer?.backgroundColor = NSColor.clear.cgColor
    window.isMovableByWindowBackground = true
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.center()

    self.window = window

    NSApp.activate(ignoringOtherApps: true)
    window.makeKeyAndOrderFront(nil)
    window.orderFrontRegardless()
    window.invalidateShadow()
  }
}

@main
struct MacPetWidgetApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}
