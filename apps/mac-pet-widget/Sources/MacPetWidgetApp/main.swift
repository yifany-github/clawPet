import SwiftUI

@main
struct MacPetWidgetApp: App {
  var body: some Scene {
    WindowGroup {
      VStack(spacing: 8) {
        Text("Clawy")
          .font(.headline)
        Text("Bridge connected")
          .font(.caption)
      }
      .padding(16)
      .frame(minWidth: 180, minHeight: 120)
    }
  }
}
