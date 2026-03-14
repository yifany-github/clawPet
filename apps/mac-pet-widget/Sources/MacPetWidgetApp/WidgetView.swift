import AppKit
import SwiftUI

struct WidgetRootView: View {
  @EnvironmentObject private var store: BridgeStore
  @State private var showSettings = false
  @State private var bridgeDraft = ""
  @State private var gearRotation = -15.0
  @State private var gearScale = 1.0
  @State private var gearFlash = 0.12
  @State private var petAnimated = false
  @State private var windowDragOrigin: CGPoint?

  var body: some View {
    ZStack {
      Color.clear
      widget
    }
    .frame(width: 456, height: 392)
    .contextMenu {
      Button("Refresh") {
        store.refreshNow()
      }
      Button("Settings") {
        showSettings = true
      }
      Divider()
      Button("Quit") {
        NSApp.terminate(nil)
      }
    }
    .sheet(isPresented: $showSettings) {
      settingsView
    }
    .onAppear {
      bridgeDraft = store.bridgeURLString
      petAnimated = true
      store.start()
    }
  }

  private var widget: some View {
    ZStack(alignment: .topLeading) {
      Ellipse()
        .fill(Color.black.opacity(0.2))
        .frame(width: 280, height: 28)
        .blur(radius: 20)
        .position(x: 174, y: 194)

      leftSideButton
        .position(x: 20, y: 108)

      topButton
        .position(x: 120, y: 16)

      gear
        .position(x: 320, y: 132)

      plasticBody
        .position(x: 184, y: 180)
    }
    .frame(width: 456, height: 392)
  }

  private var plasticBody: some View {
    let shape = ReactBodyShape()

    return ZStack(alignment: .topLeading) {
      shape
        .fill(
          RadialGradient(
            colors: [
              Color(hex: 0x4ADE80),
              Color(hex: 0x22C55E),
              Color(hex: 0x16A34A)
            ],
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: 230
          )
        )
        .overlay(
          shape
            .stroke(Color.white.opacity(0.4), lineWidth: 24)
            .blur(radius: 10)
            .offset(x: -10, y: -10)
            .mask(shape)
        )
        .overlay(
          shape
            .stroke(Color(hex: 0x15803D), lineWidth: 3)
        )
        .overlay(
          shape
            .stroke(Color.black.opacity(0.2), lineWidth: 24)
            .blur(radius: 10)
            .offset(x: 10, y: 10)
            .mask(shape)
        )

      smallScreen
        .offset(x: 24, y: 24)

      mainScreen
        .offset(x: 39, y: 39)
    }
    .frame(width: 320, height: 320)
    .contentShape(shape)
    .gesture(windowDragGesture)
  }

  private var windowDragGesture: some Gesture {
    DragGesture(minimumDistance: 1)
      .onChanged { value in
        guard let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "clawpet-window" }) else {
          return
        }

        if windowDragOrigin == nil {
          windowDragOrigin = window.frame.origin
        }

        guard let origin = windowDragOrigin else {
          return
        }

        window.setFrameOrigin(
          NSPoint(
            x: origin.x + value.translation.width,
            y: origin.y - value.translation.height
          )
        )
      }
      .onEnded { _ in
        windowDragOrigin = nil
      }
  }

  private func spinGear(from delta: CGFloat) {
    let adjusted = abs(delta) < 1 ? delta * 18 : delta
    let direction = adjusted == 0 ? 0.0 : (adjusted > 0 ? 1.0 : -1.0)
    let magnitude = max(10.0, min(42.0, abs(Double(adjusted)) * 0.9))

    withAnimation(.interactiveSpring(response: 0.18, dampingFraction: 0.82)) {
      gearRotation += magnitude * direction
      gearFlash = 0.22
    }

    Task {
      try? await Task.sleep(nanoseconds: 140_000_000)
      await MainActor.run {
        withAnimation(.easeOut(duration: 0.18)) {
          gearFlash = 0.12
        }
      }
    }
  }

  private func clickGear() {
    withAnimation(.easeOut(duration: 0.08)) {
      gearScale = 0.94
      gearFlash = 0.28
    }
    store.toggleBubble()

    Task {
      try? await Task.sleep(nanoseconds: 120_000_000)
      await MainActor.run {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
          gearScale = 1.0
          gearFlash = 0.12
        }
      }
    }
  }

  private var leftSideButton: some View {
    Button {
      showSettings = true
    } label: {
      ZStack {
        LeftSideButtonShape()
          .fill(Color(hex: 0xFACC15))
          .frame(width: 24, height: 64)
          .overlay(
            LeftSideButtonShape()
              .stroke(Color.white.opacity(0.4), lineWidth: 10)
              .blur(radius: 4)
              .offset(x: -2, y: -2)
              .mask(LeftSideButtonShape())
          )
          .overlay(
            LeftSideButtonShape()
              .stroke(Color(hex: 0xCA8A04), lineWidth: 2)
          )
          .overlay(
            LeftSideButtonShape()
              .stroke(Color.black.opacity(0.2), lineWidth: 10)
              .blur(radius: 4)
              .offset(x: 2, y: 2)
              .mask(LeftSideButtonShape())
          )
          .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
      }
    }
    .buttonStyle(LeftPlasticButtonStyle())
  }

  private var topButton: some View {
    Button {
      store.refreshNow()
    } label: {
      ZStack {
        TopButtonShape()
          .fill(Color(hex: 0xFACC15))
          .frame(width: 64, height: 24)
          .overlay(
            TopButtonShape()
              .stroke(Color.white.opacity(0.4), lineWidth: 10)
              .blur(radius: 4)
              .offset(x: -2, y: -2)
              .mask(TopButtonShape())
          )
          .overlay(
            TopButtonShape()
              .stroke(Color(hex: 0xCA8A04), lineWidth: 2)
          )
          .overlay(
            TopButtonShape()
              .stroke(Color.black.opacity(0.2), lineWidth: 10)
              .blur(radius: 4)
              .offset(x: 2, y: 2)
              .mask(TopButtonShape())
          )
          .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
      }
    }
    .buttonStyle(TopPlasticButtonStyle())
  }

  private var gear: some View {
    ZStack {
      GearDecoration(rotation: gearRotation)
        .frame(width: 160, height: 160)
        .scaleEffect(gearScale)

      Circle()
        .fill(
          RadialGradient(
            colors: [
              Color.white.opacity(gearFlash),
              .clear
            ],
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: 38
          )
        )
        .frame(width: 76, height: 76)

      GearEventCatcher(
        onScroll: { delta in
          spinGear(from: delta)
        },
        onClick: {
          clickGear()
        }
      )
      .frame(width: 160, height: 160)
    }
    .frame(width: 160, height: 160)
  }

  private var smallScreen: some View {
    ZStack {
      Circle()
        .fill(Color(hex: 0x27272A))
        .frame(width: 48, height: 48)
        .overlay(Circle().stroke(Color(hex: 0x18181B), lineWidth: 3))
        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

      Circle()
        .fill(Color(hex: 0x9EA786))
        .frame(width: 38, height: 38)
        .overlay {
          GeometryReader { proxy in
            ZStack {
              CenteredEmojiGlyph(emoji: connectionEmoji)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2 + 4)
            }
            LCDGridOverlay(step: 3, opacity: 0.03)
            SmallScreenScanlineOverlay()
            SmallScreenToneOverlay()
            DiagonalGlareOverlay()
          }
          .clipShape(Circle())
        }
    }
  }

  private var mainScreen: some View {
    ZStack {
      Circle()
        .fill(Color(hex: 0x27272A))
        .frame(width: 242, height: 242)
        .overlay(
          Circle()
            .stroke(Color(hex: 0x18181B), lineWidth: 10)
        )
        .shadow(color: .black.opacity(0.22), radius: 10, y: 4)

      Circle()
        .fill(Color(hex: 0x9EA786))
        .frame(width: 238, height: 238)
        .overlay(
          Circle()
            .stroke(Color(hex: 0x3F3F46).opacity(0.5), lineWidth: 4)
        )
        .overlay {
          ZStack {
            LCDGridOverlay(step: 4, opacity: 0.05)
            MainScreenToneOverlay()
            MainScreenScanlineOverlay()
            ScreenGlare()

            VStack {
              iconRow
                .padding(.horizontal, 26)
                .padding(.top, 4)
              Spacer()
              PetBlob(isAnimating: petAnimated)
              Spacer()
              Text("LVL 01")
                .font(.system(size: 38, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.black.opacity(0.8))
                .tracking(4)
                .padding(.bottom, 18)
            }
            .padding(14)
          }
          .clipShape(Circle())
        }
    }
    .frame(width: 242, height: 242)
  }

  private var iconRow: some View {
    HStack {
      mainIconOne
      Spacer()
      mainIconTwo
      Spacer()
      mainIconThree
      Spacer()
      mainIconFour
    }
    .frame(height: 20)
  }

  private var mainIconOne: some View {
    ZStack(alignment: .bottom) {
      Rectangle()
        .fill(Color.black.opacity(0.7))
        .frame(width: 16, height: 16)
      Capsule()
        .fill(Color(red: 0.62, green: 0.65, blue: 0.53))
        .frame(width: 10, height: 7)
        .offset(y: -2)
    }
  }

  private var mainIconTwo: some View {
    ZStack(alignment: .bottomLeading) {
      Circle()
        .fill(Color.black.opacity(0.7))
        .frame(width: 16, height: 16)
      Rectangle()
        .fill(Color.black.opacity(0.7))
        .frame(width: 8, height: 6)
        .offset(x: 4, y: 3)
    }
  }

  private var mainIconThree: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 2, style: .continuous)
        .fill(Color.black.opacity(0.7))
        .frame(width: 16, height: 16)
      Circle()
        .fill(Color(red: 0.62, green: 0.65, blue: 0.53))
        .frame(width: 8, height: 8)
    }
  }

  private var mainIconFour: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 2, style: .continuous)
        .fill(Color.black.opacity(0.7))
        .frame(width: 16, height: 16)
      Rectangle()
        .fill(Color(red: 0.62, green: 0.65, blue: 0.53))
        .frame(width: 10, height: 2)
      Rectangle()
        .fill(Color(red: 0.62, green: 0.65, blue: 0.53))
        .frame(width: 2, height: 10)
    }
  }

  private var settingsView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("ClawPet Settings")
        .font(.headline)

      Text("Bridge URL")
        .font(.subheadline)
      TextField("http://127.0.0.1:8787", text: $bridgeDraft)
        .textFieldStyle(.roundedBorder)

      HStack {
        Spacer()
        Button("Cancel") {
          showSettings = false
          bridgeDraft = store.bridgeURLString
        }
        Button("Save") {
          store.setBridgeURL(bridgeDraft)
          showSettings = false
        }
        .keyboardShortcut(.defaultAction)
      }
    }
    .padding(18)
    .frame(width: 360)
  }

  private var connectionEmoji: String {
    "🤣"
  }
}

private struct ReactBodyShape: Shape {
  func path(in rect: CGRect) -> Path {
    let tl: CGFloat = 56
    let r = min(rect.width, rect.height) * 0.5

    var path = Path()
    path.move(to: CGPoint(x: tl, y: 0))
    path.addLine(to: CGPoint(x: rect.width - r, y: 0))
    path.addArc(
      center: CGPoint(x: rect.width - r, y: rect.height * 0.5),
      radius: r,
      startAngle: .degrees(-90),
      endAngle: .degrees(180),
      clockwise: false
    )
    path.addLine(to: CGPoint(x: 0, y: tl))
    path.addArc(
      center: CGPoint(x: tl, y: tl),
      radius: tl,
      startAngle: .degrees(180),
      endAngle: .degrees(270),
      clockwise: false
    )
    return path
  }
}

private struct LeftSideButtonShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let r: CGFloat = 8
    path.move(to: CGPoint(x: rect.width, y: 0))
    path.addLine(to: CGPoint(x: r, y: 0))
    path.addQuadCurve(to: CGPoint(x: 0, y: r), control: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: 0, y: rect.height - r))
    path.addQuadCurve(to: CGPoint(x: r, y: rect.height), control: CGPoint(x: 0, y: rect.height))
    path.addLine(to: CGPoint(x: rect.width, y: rect.height))
    path.closeSubpath()
    return path
  }
}

private struct TopButtonShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let r: CGFloat = 8
    path.move(to: CGPoint(x: 0, y: rect.height))
    path.addLine(to: CGPoint(x: 0, y: r))
    path.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: rect.width - r, y: 0))
    path.addQuadCurve(to: CGPoint(x: rect.width, y: r), control: CGPoint(x: rect.width, y: 0))
    path.addLine(to: CGPoint(x: rect.width, y: rect.height))
    path.closeSubpath()
    return path
  }
}

private struct GearDecoration: View {
  let rotation: Double

  var body: some View {
    ZStack {
      ForEach(0..<8, id: \.self) { idx in
        RoundedRectangle(cornerRadius: 1, style: .continuous)
          .fill(
            LinearGradient(
              colors: [
                Color(hex: 0x6A6A6A),
                Color(hex: 0x3A3A3A),
                Color(hex: 0x1A1A1A)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 8, height: 16)
          .offset(y: -20)
          .overlay(
            RoundedRectangle(cornerRadius: 1, style: .continuous)
              .stroke(Color.black.opacity(0.35), lineWidth: 0.5)
          )
          .rotationEffect(.degrees(rotation + Double(idx) * 45))
      }

      Circle()
        .fill(
          LinearGradient(
            colors: [
              Color(hex: 0x5A5A5A),
              Color(hex: 0x2A2A2A),
              Color(hex: 0x1A1A1A)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .frame(width: 72, height: 72)
        .overlay(Circle().stroke(Color.black.opacity(0.65), lineWidth: 1))

      Circle()
        .fill(Color(hex: 0x2A2A2A))
        .frame(width: 48, height: 48)
        .overlay(Circle().stroke(Color.black.opacity(0.65), lineWidth: 1))

      Circle()
        .fill(Color(hex: 0x1A1A1A))
        .frame(width: 24, height: 24)

      Circle()
        .fill(
          RadialGradient(
            colors: [
              Color.white.opacity(0.1),
              .clear
            ],
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: 36
          )
        )
        .frame(width: 72, height: 72)

      RoundedRectangle(cornerRadius: 3, style: .continuous)
        .fill(Color.white.opacity(0.16))
        .frame(width: 18, height: 6)
        .offset(y: -26)
        .rotationEffect(.degrees(rotation - 18))

      ZStack {
        Circle()
          .trim(from: 0.78, to: 0.93)
          .stroke(
            Color.white.opacity(0.34),
            style: StrokeStyle(lineWidth: 4, lineCap: .round)
          )
          .frame(width: 66, height: 66)

        Circle()
          .trim(from: 0.1, to: 0.18)
          .stroke(
            Color(hex: 0xFACC15).opacity(0.9),
            style: StrokeStyle(lineWidth: 3, lineCap: .round)
          )
          .frame(width: 58, height: 58)

        ForEach(0..<12, id: \.self) { idx in
          Capsule(style: .continuous)
            .fill(Color(hex: 0xFACC15).opacity(yellowTickOpacity(idx)))
            .frame(width: idx < 3 ? 12 : 9, height: 3)
            .offset(y: -29)
            .rotationEffect(.degrees(Double(idx) * 30))
        }

        ForEach(0..<12, id: \.self) { idx in
          Circle()
            .fill(Color(hex: 0xFACC15).opacity(yellowDotOpacity(idx)))
            .frame(
              width: idx == 0 ? 8 : (idx < 3 ? 6 : 4.5),
              height: idx == 0 ? 8 : (idx < 3 ? 6 : 4.5)
            )
            .offset(y: -22)
            .rotationEffect(.degrees(Double(idx) * 30 + 12))
            .shadow(
              color: Color(hex: 0xFACC15).opacity(idx < 3 ? 0.4 : 0.18),
              radius: idx < 3 ? 4 : 2
            )
        }

        Capsule(style: .continuous)
          .fill(Color.black.opacity(0.45))
          .frame(width: 12, height: 4)
          .offset(x: -18, y: 18)
      }
      .rotationEffect(.degrees(rotation))
    }
    .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 2)
  }

  private func yellowTickOpacity(_ idx: Int) -> Double {
    [1.0, 0.92, 0.82, 0.58, 0.4, 0.28, 0.2, 0.16, 0.16, 0.2, 0.3, 0.52][idx]
  }

  private func yellowDotOpacity(_ idx: Int) -> Double {
    [0.95, 0.78, 0.62, 0.42, 0.28, 0.2, 0.16, 0.14, 0.14, 0.18, 0.24, 0.38][idx]
  }
}

private struct GearEventCatcher: NSViewRepresentable {
  let onScroll: (CGFloat) -> Void
  let onClick: () -> Void

  func makeNSView(context: Context) -> GearEventView {
    let view = GearEventView()
    view.onScroll = onScroll
    view.onClick = onClick
    return view
  }

  func updateNSView(_ nsView: GearEventView, context: Context) {
    nsView.onScroll = onScroll
    nsView.onClick = onClick
  }
}

private struct CenteredEmojiGlyph: View {
  let emoji: String

  var body: some View {
    Image(nsImage: EmojiGlyphRenderer.image(for: emoji))
      .resizable()
      .interpolation(.high)
      .aspectRatio(contentMode: .fit)
      .frame(width: 38, height: 38)
  }
}

private enum EmojiGlyphRenderer {
  static func image(for emoji: String) -> NSImage {
    let canvasSide = 128
    let fontSize: CGFloat = 60

    guard let rep = NSBitmapImageRep(
      bitmapDataPlanes: nil,
      pixelsWide: canvasSide,
      pixelsHigh: canvasSide,
      bitsPerSample: 8,
      samplesPerPixel: 4,
      hasAlpha: true,
      isPlanar: false,
      colorSpaceName: .deviceRGB,
      bytesPerRow: 0,
      bitsPerPixel: 0
    ) else {
      return NSImage(size: NSSize(width: 1, height: 1))
    }

    rep.size = NSSize(width: canvasSide, height: canvasSide)

    NSGraphicsContext.saveGraphicsState()
    guard let context = NSGraphicsContext(bitmapImageRep: rep) else {
      NSGraphicsContext.restoreGraphicsState()
      return NSImage(size: NSSize(width: 1, height: 1))
    }
    NSGraphicsContext.current = context

    NSColor.clear.setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: canvasSide, height: canvasSide)).fill()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center

    let attributes: [NSAttributedString.Key: Any] = [
      .font: NSFont(name: "AppleColorEmoji", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize),
      .paragraphStyle: paragraph
    ]

    let string = NSString(string: emoji)
    let glyphSize = string.size(withAttributes: attributes)
    let drawPoint = NSPoint(
      x: (CGFloat(canvasSide) - glyphSize.width) / 2,
      y: (CGFloat(canvasSide) - glyphSize.height) / 2 + 3
    )
    string.draw(at: drawPoint, withAttributes: attributes)
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()

    let cropRect = expandedEmojiBounds(from: nonTransparentBounds(in: rep), in: rep)
    guard cropRect.width > 0, cropRect.height > 0 else {
      let image = NSImage(size: NSSize(width: canvasSide, height: canvasSide))
      image.addRepresentation(rep)
      return image
    }

    let cropped = NSImage(size: cropRect.size)
    cropped.lockFocus()
    rep.draw(
      in: NSRect(origin: .zero, size: cropRect.size),
      from: cropRect,
      operation: .copy,
      fraction: 1.0,
      respectFlipped: false,
      hints: nil
    )
    cropped.unlockFocus()
    return cropped
  }

  private static func nonTransparentBounds(in rep: NSBitmapImageRep) -> NSRect {
    let width = rep.pixelsWide
    let height = rep.pixelsHigh

    var minX = width
    var minY = height
    var maxX = -1
    var maxY = -1

    for y in 0..<height {
      for x in 0..<width {
        guard let color = rep.colorAt(x: x, y: y), color.alphaComponent > 0.01 else {
          continue
        }
        minX = min(minX, x)
        minY = min(minY, y)
        maxX = max(maxX, x)
        maxY = max(maxY, y)
      }
    }

    guard maxX >= minX, maxY >= minY else {
      return .zero
    }

    return NSRect(
      x: minX,
      y: minY,
      width: maxX - minX + 1,
      height: maxY - minY + 1
    )
  }

  private static func expandedEmojiBounds(from rect: NSRect, in rep: NSBitmapImageRep) -> NSRect {
    guard rect.width > 0, rect.height > 0 else {
      return rect
    }

    let left = max(0, rect.minX - 2)
    let bottom = max(0, rect.minY - 2)
    let right = min(CGFloat(rep.pixelsWide), rect.maxX + 2)
    let top = min(CGFloat(rep.pixelsHigh), rect.maxY + 8)

    return NSRect(
      x: left,
      y: bottom,
      width: right - left,
      height: top - bottom
    )
  }
}

private final class GearEventView: NSView {
  var onScroll: ((CGFloat) -> Void)?
  var onClick: (() -> Void)?

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var acceptsFirstResponder: Bool {
    true
  }

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    true
  }

  override func hitTest(_ point: NSPoint) -> NSView? {
    bounds.contains(point) ? self : nil
  }

  override func scrollWheel(with event: NSEvent) {
    onScroll?(event.scrollingDeltaY)
  }

  override func mouseDown(with event: NSEvent) {
    onClick?()
  }
}

private struct LeftPlasticButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .overlay {
        Capsule(style: .continuous)
          .fill(Color.black.opacity(0.1))
          .frame(width: 4, height: 32)
          .opacity(configuration.isPressed ? 1 : 0)
      }
      .offset(x: configuration.isPressed ? 1 : 0)
      .animation(.easeOut(duration: 0.075), value: configuration.isPressed)
  }
}

private struct TopPlasticButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .overlay {
        Capsule(style: .continuous)
          .fill(Color.black.opacity(0.1))
          .frame(width: 32, height: 4)
          .opacity(configuration.isPressed ? 1 : 0)
      }
      .offset(y: configuration.isPressed ? 1 : 0)
      .animation(.easeOut(duration: 0.075), value: configuration.isPressed)
  }
}

private struct LCDGridOverlay: View {
  let step: CGFloat
  let opacity: Double

  var body: some View {
    GeometryReader { proxy in
      Path { path in
        stride(from: 0.0, through: proxy.size.width, by: step).forEach { x in
          path.move(to: CGPoint(x: x, y: 0))
          path.addLine(to: CGPoint(x: x, y: proxy.size.height))
        }
        stride(from: 0.0, through: proxy.size.height, by: step).forEach { y in
          path.move(to: CGPoint(x: 0, y: y))
          path.addLine(to: CGPoint(x: proxy.size.width, y: y))
        }
      }
      .stroke(Color.black.opacity(opacity), lineWidth: 1)
    }
  }
}

private struct SmallScreenScanlineOverlay: View {
  var body: some View {
    GeometryReader { proxy in
      VStack(spacing: 0) {
        ForEach(0..<Int(ceil(proxy.size.height / 2)), id: \.self) { idx in
          Rectangle()
            .fill(idx.isMultiple(of: 2) ? Color.clear : Color.black.opacity(0.15))
            .frame(height: 2)
        }
      }
    }
  }
}

private struct SmallScreenToneOverlay: View {
  var body: some View {
    LinearGradient(
      colors: [
        Color(hex: 0x9EA786).opacity(0.4),
        .clear,
        Color(hex: 0x9EA786).opacity(0.3)
      ],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}

private struct MainScreenToneOverlay: View {
  var body: some View {
    LinearGradient(
      colors: [
        Color(hex: 0x9EA786).opacity(0.16),
        .clear,
        Color(hex: 0x9EA786).opacity(0.1)
      ],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}

private struct MainScreenScanlineOverlay: View {
  var body: some View {
    GeometryReader { proxy in
      VStack(spacing: 0) {
        ForEach(0..<Int(ceil(proxy.size.height / 2)), id: \.self) { idx in
          Rectangle()
            .fill(idx.isMultiple(of: 2) ? Color.clear : Color.black.opacity(0.1))
            .frame(height: 2)
        }
      }
    }
  }
}

private struct DiagonalGlareOverlay: View {
  var body: some View {
    LinearGradient(
      stops: [
        .init(color: .clear, location: 0.4),
        .init(color: .white.opacity(0.3), location: 0.5),
        .init(color: .clear, location: 0.6)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    .rotationEffect(.degrees(-25))
    .opacity(0.3)
  }
}

private struct ScreenGlare: View {
  var body: some View {
    GeometryReader { proxy in
      Ellipse()
        .fill(
          LinearGradient(
            colors: [
              .white.opacity(0.15),
              .clear
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .frame(width: proxy.size.width * 0.9, height: proxy.size.height * 0.45)
        .offset(x: proxy.size.width * 0.05, y: proxy.size.height * 0.05)
    }
  }
}

private extension Color {
  init(hex: Int, opacity: Double = 1.0) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255.0,
      green: Double((hex >> 8) & 0xFF) / 255.0,
      blue: Double(hex & 0xFF) / 255.0,
      opacity: opacity
    )
  }
}

private struct PetBlob: View {
  let isAnimating: Bool

  var body: some View {
    ZStack {
      UnevenPetBodyShape()
        .fill(Color.black.opacity(0.8))
        .frame(width: 64, height: 56)

      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
          .fill(Color(red: 0.62, green: 0.65, blue: 0.53))
          .frame(width: 12, height: 12)
        Rectangle()
          .fill(Color.black.opacity(0.8))
          .frame(width: 4, height: 4)
          .offset(x: 4, y: 4)
      }
      .offset(x: -10, y: -6)

      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
          .fill(Color(red: 0.62, green: 0.65, blue: 0.53))
          .frame(width: 12, height: 12)
        Rectangle()
          .fill(Color.black.opacity(0.8))
          .frame(width: 4, height: 4)
          .offset(x: 4, y: 4)
      }
      .offset(x: 10, y: -6)

      Capsule()
        .fill(Color(red: 0.62, green: 0.65, blue: 0.53))
        .frame(width: 16, height: 8)
        .offset(y: 10)

      Capsule()
        .fill(Color.black.opacity(0.8))
        .frame(width: 8, height: 16)
        .rotationEffect(.degrees(12))
        .offset(x: -30, y: 8)

      Capsule()
        .fill(Color.black.opacity(0.8))
        .frame(width: 8, height: 16)
        .rotationEffect(.degrees(-12))
        .offset(x: 30, y: 8)
    }
    .scaleEffect(x: isAnimating ? 1.1 : 1.0, y: isAnimating ? 0.8 : 1.0)
    .offset(y: isAnimating ? 4 : 0)
    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
    .overlay(
      Ellipse()
        .fill(Color.black.opacity(0.1))
        .frame(width: 48, height: 8)
        .offset(y: 38)
    )
  }
}

private struct UnevenPetBodyShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let topRadius = min(rect.width, rect.height) * 0.43
    let bottomRadius: CGFloat = 8

    path.move(to: CGPoint(x: bottomRadius, y: rect.height))
    path.addLine(to: CGPoint(x: rect.width - bottomRadius, y: rect.height))
    path.addQuadCurve(
      to: CGPoint(x: rect.width, y: rect.height - bottomRadius),
      control: CGPoint(x: rect.width, y: rect.height)
    )
    path.addLine(to: CGPoint(x: rect.width, y: topRadius))
    path.addQuadCurve(
      to: CGPoint(x: rect.width - topRadius, y: 0),
      control: CGPoint(x: rect.width, y: 0)
    )
    path.addLine(to: CGPoint(x: topRadius, y: 0))
    path.addQuadCurve(
      to: CGPoint(x: 0, y: topRadius),
      control: CGPoint(x: 0, y: 0)
    )
    path.addLine(to: CGPoint(x: 0, y: rect.height - bottomRadius))
    path.addQuadCurve(
      to: CGPoint(x: bottomRadius, y: rect.height),
      control: CGPoint(x: 0, y: rect.height)
    )
    return path
  }
}
