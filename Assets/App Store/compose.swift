#!/usr/bin/env swift

import AppKit

let scriptDir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let languages = ["en", "ja"]
/// The devices named on the command line (`./compose.swift Mac`), or all of them.
let requestedDevices = Set(CommandLine.arguments.dropFirst())

/// Captures live in `Raw/<device>/<lang>/` and are written to `<device>/<lang>/`. Watch shots need no framing, so
/// `capture-watch.sh` writes them straight to `Watch/<lang>/`.
enum Device: String {
    case iPhone
    case iPad
    case mac = "Mac"

    /// 6.5" iPhone, 13" iPad, and the Mac's 16:10.
    var canvasSize: NSSize {
        switch self {
        case .iPhone: NSSize(width: 1242, height: 2688)
        case .iPad: NSSize(width: 2064, height: 2752)
        case .mac: NSSize(width: 2880, height: 1800)
        }
    }

    var isRequested: Bool { requestedDevices.isEmpty || requestedDevices.contains(rawValue) }

    /// Text and margins are laid out for the iPhone canvas and scaled up by width.
    var scale: CGFloat { canvasSize.width / Device.iPhone.canvasSize.width }

    func rawDir(_ language: String) -> URL {
        scriptDir.appendingPathComponent("Raw").appendingPathComponent(rawValue)
            .appendingPathComponent(language)
    }

    func outDir(_ language: String) -> URL {
        scriptDir.appendingPathComponent(rawValue).appendingPathComponent(language)
    }
}

struct Copy {
    let header: String
}

struct Screenshot {
    let name: String
    let icon: Icon
    /// Keyed by language code. A language without copy is skipped.
    let copy: [String: Copy]
}

func color(_ hex: UInt32) -> NSColor {
    NSColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: 1
    )
}

// The app's burgundy accent, deepening toward the bottom.
let accent = color(0x8D2A47)
let gradientTop = accent
let gradientBottom = accent.blended(withFraction: 0.3, of: .black)!

let weekCopy = [
    "en": Copy(header: "See your whole week at once"),
    "ja": Copy(header: "今週の予定、全部見える"),
]
let listsCopy = [
    "en": Copy(header: "Tick things off as you go"),
    "ja": Copy(header: "終わったらチェックするだけ"),
]
let notesCopy = [
    "en": Copy(header: "Jot it down in Markdown"),
    "ja": Copy(header: "メモはMarkdownでさっと"),
]
let alarmsCopy = [
    "en": Copy(header: "Set alarms right from your calendar"),
    "ja": Copy(header: "カレンダーからアラームをセット"),
]
let notificationsCopy = [
    "en": Copy(header: "Pick how each calendar alerts you"),
    "ja": Copy(header: "通知の鳴らし方は自分で決める"),
]
let countdownCopy = [
    "en": Copy(header: "See how long until your next event"),
    "ja": Copy(header: "次の予定まで、あと何分?"),
]

let iPhoneScreenshots = [
    Screenshot(name: "01-week", icon: .calendar, copy: weekCopy),
    Screenshot(name: "02-lists", icon: .reminders, copy: listsCopy),
    Screenshot(name: "03-notes", icon: .notes, copy: notesCopy),
    Screenshot(name: "04-alarms", icon: .alarm, copy: alarmsCopy),
    Screenshot(name: "05-notifications", icon: .bell, copy: notificationsCopy),
    Screenshot(name: "06-countdown", icon: .timer, copy: countdownCopy),
]

// The iPad has no countdown, as Live Activities are off there unless turned on.
let iPadScreenshots = Array(iPhoneScreenshots.dropLast())

let macScreenshots = [
    Screenshot(
        name: "01-week",
        icon: .calendar,
        copy: [
            "en": Copy(header: "Your whole week, on your Mac"),
            "ja": Copy(header: "1週間まるごと、Macで"),
        ]
    ),
    Screenshot(name: "02-lists", icon: .reminders, copy: listsCopy),
    Screenshot(name: "03-notes", icon: .notes, copy: notesCopy),
    Screenshot(name: "04-notifications", icon: .bell, copy: notificationsCopy),
]

// MARK: - Icons

/// A classic app-icon tile above each header: a colored tile with a slight gradient and a white glyph.
enum Icon {
    case calendar
    case reminders
    case notes
    case alarm
    case bell
    case timer

    var symbolName: String {
        switch self {
        case .calendar: "calendar"
        case .reminders: "checklist"
        case .notes: "note.text"
        case .alarm: "alarm.fill"
        case .bell: "bell.fill"
        case .timer: "timer"
        }
    }

    var tileColor: NSColor {
        switch self {
        case .calendar: color(0xFF3B30)
        case .reminders: color(0x007AFF)
        case .notes: color(0xFFB800)
        case .alarm: color(0xFF9500)
        case .bell: color(0xFF2D55)
        case .timer: color(0x34C759)
        }
    }

    func draw(in rect: NSRect) {
        let tile = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.225, yRadius: rect.width * 0.225)
        NSGraphicsContext.current?.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
        shadow.shadowBlurRadius = rect.width * 0.11
        shadow.shadowOffset = NSSize(width: 0, height: -rect.width * 0.045)
        shadow.set()
        tileColor.setFill()
        tile.fill()
        NSGraphicsContext.current?.restoreGraphicsState()
        // Lit from above: a little lighter at the top and darker at the bottom.
        NSGradient(
            starting: tileColor.blended(withFraction: 0.18, of: .white)!,
            ending: tileColor.blended(withFraction: 0.12, of: .black)!
        )?.draw(in: tile, angle: -90)

        let configuration = NSImage.SymbolConfiguration(pointSize: rect.width * 0.5, weight: .medium)
            .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
        let glyph = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)!
            .withSymbolConfiguration(configuration)!
        NSGraphicsContext.current?.saveGraphicsState()
        let glyphShadow = NSShadow()
        glyphShadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
        glyphShadow.shadowBlurRadius = rect.width * 0.02
        glyphShadow.shadowOffset = NSSize(width: 0, height: -rect.width * 0.012)
        glyphShadow.set()
        glyph.draw(in: NSRect(
            x: rect.midX - glyph.size.width / 2, y: rect.midY - glyph.size.height / 2,
            width: glyph.size.width, height: glyph.size.height
        ))
        NSGraphicsContext.current?.restoreGraphicsState()
    }

    /// Draws the tile centered across `canvasWidth`, with its top at `top`.
    func draw(size: CGFloat, top: CGFloat, canvasWidth: CGFloat) {
        draw(in: NSRect(x: ((canvasWidth - size) / 2).rounded(), y: (top - size).rounded(), width: size, height: size))
    }
}

// MARK: - Text

/// SF Pro Display at these sizes. Japanese falls back to Hiragino Sans.
func displayFont(ofSize size: CGFloat, weight: NSFont.Weight) -> NSFont {
    NSFont.systemFont(ofSize: size, weight: weight)
}

/// One line of text at the largest size up to `size` that fits `maxWidth`.
struct Line {
    let text: String
    let attributes: [NSAttributedString.Key: Any]
    let font: NSFont
    let size: NSSize

    init(_ text: String, size: CGFloat, weight: NSFont.Weight, color: NSColor, maxWidth: CGFloat) {
        var fontSize = size
        var font = displayFont(ofSize: fontSize, weight: weight)
        var attributes: [NSAttributedString.Key: Any] = [:]
        var lineSize = NSSize.zero
        while fontSize > 10 {
            font = displayFont(ofSize: fontSize, weight: weight)
            attributes = [.font: font, .foregroundColor: color]
            lineSize = (text as NSString).size(withAttributes: attributes)
            if lineSize.width <= maxWidth { break }
            fontSize -= 2
        }
        self.text = text
        self.attributes = attributes
        self.font = font
        self.size = lineSize
        (inkTop, inkBottom) = Line.inkInsets(of: text, attributes: attributes, size: lineSize)
    }

    /// How far below the top of the line box the glyphs actually start and end.
    let inkTop: CGFloat
    let inkBottom: CGFloat

    /// Centering by font metrics leaves the text looking off, since the line box carries
    /// space above the capitals and below the baseline. So the line is rendered once and
    /// the rows its glyphs cover are measured.
    private static func inkInsets(
        of text: String, attributes: [NSAttributedString.Key: Any], size: NSSize
    ) -> (CGFloat, CGFloat) {
        let width = Int(size.width.rounded(.up))
        let height = Int(size.height.rounded(.up))
        guard width > 0, height > 0, let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) else { return (0, size.height) }
        bitmap.size = NSSize(width: width, height: height)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        var opaque = attributes
        opaque[.foregroundColor] = NSColor.black
        (text as NSString).draw(at: .zero, withAttributes: opaque)
        NSGraphicsContext.restoreGraphicsState()

        // Bitmap rows run top to bottom.
        let inked = (0..<height).filter { y in
            (0..<width).contains { x in (bitmap.colorAt(x: x, y: y)?.alphaComponent ?? 0) > 0.1 }
        }
        guard let first = inked.first, let last = inked.last else { return (0, size.height) }
        return (CGFloat(first), CGFloat(last + 1))
    }

    /// Draws the line centered across `canvasWidth`, with the top of its line box at `top`.
    func draw(top: CGFloat, canvasWidth: CGFloat) {
        (text as NSString).draw(
            at: NSPoint(x: (canvasWidth - size.width) / 2, y: top - size.height),
            withAttributes: attributes
        )
    }
}

// MARK: - Device frames

func cgImage(of image: NSImage) -> CGImage {
    image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
}

/// Draws `raw` aspect-filled into `rect`.
func drawFilled(_ raw: CGImage, in rect: CGRect, context: CGContext) {
    let rawSize = CGSize(width: raw.width, height: raw.height)
    let scale = max(rect.width / rawSize.width, rect.height / rawSize.height)
    let drawSize = CGSize(width: rawSize.width * scale, height: rawSize.height * scale)
    context.draw(raw, in: CGRect(
        x: rect.midX - drawSize.width / 2,
        y: rect.midY - drawSize.height / 2,
        width: drawSize.width,
        height: drawSize.height
    ))
}

let hardwareImage = NSImage(contentsOf: scriptDir.appendingPathComponent("Hardware@2x.png"))!
let displayImage = NSImage(contentsOf: scriptDir.appendingPathComponent("Display@2x.png"))!
let hardwareCG = cgImage(of: hardwareImage)
let displayCG = cgImage(of: displayImage)
let hardwarePixel = NSSize(width: hardwareCG.width, height: hardwareCG.height)
let displayPixel = NSSize(width: displayCG.width, height: displayCG.height)
// The display mask sits centered within the hardware frame.
let displayOrigin = NSPoint(
    x: (hardwarePixel.width - displayPixel.width) / 2,
    y: (hardwarePixel.height - displayPixel.height) / 2
)

/// The raw capture clipped by the display mask, on a hardware-sized canvas.
func maskedScreen(raw: NSImage) -> NSImage {
    let image = NSImage(size: hardwarePixel)
    image.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    let displayRect = CGRect(origin: displayOrigin, size: displayPixel)
    ctx.clip(to: displayRect, mask: displayCG)
    drawFilled(cgImage(of: raw), in: displayRect, context: ctx)
    image.unlockFocus()
    return image
}

/// The iPad bezel, as a fraction of the device's width.
let iPadBezel: CGFloat = 0.03
let iPadCornerRadius: CGFloat = 0.05
/// 13" iPad Pro screen, width over height.
let iPadScreenAspect: CGFloat = 2064 / 2752

func deviceAspect(_ device: Device) -> CGFloat {
    switch device {
    case .iPhone:
        return hardwarePixel.width / hardwarePixel.height
    case .iPad, .mac:
        let screenHeight = (1 - 2 * iPadBezel) / iPadScreenAspect
        return 1 / (screenHeight + 2 * iPadBezel)
    }
}

/// A plain iPad Pro in black, drawn rather than imaged, with the capture on its screen.
func drawiPad(raw: NSImage, in rect: NSRect) {
    let ctx = NSGraphicsContext.current!.cgContext
    let bezel = rect.width * iPadBezel
    let outerRadius = rect.width * iPadCornerRadius

    NSGraphicsContext.current?.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
    shadow.shadowBlurRadius = 60
    shadow.shadowOffset = NSSize(width: 0, height: -24)
    shadow.set()
    color(0x1C1C1E).setFill()
    NSBezierPath(roundedRect: rect, xRadius: outerRadius, yRadius: outerRadius).fill()
    NSGraphicsContext.current?.restoreGraphicsState()

    // A lighter edge, as the aluminium band catches the light.
    let rim = NSBezierPath(
        roundedRect: rect.insetBy(dx: 2, dy: 2), xRadius: outerRadius - 2, yRadius: outerRadius - 2
    )
    rim.lineWidth = 4
    color(0x5A5A5E).setStroke()
    rim.stroke()

    let screenRect = rect.insetBy(dx: bezel, dy: bezel)
    let screenRadius = max(outerRadius - bezel * 0.8, 0)
    ctx.saveGState()
    NSBezierPath(roundedRect: screenRect, xRadius: screenRadius, yRadius: screenRadius).addClip()
    drawFilled(cgImage(of: raw), in: screenRect, context: ctx)
    ctx.restoreGState()
}

// MARK: - Mac windows

/// A window capture, with the shadow macOS gives a window in front.
func drawWindow(_ raw: NSImage, in rect: NSRect) {
    NSGraphicsContext.current?.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.4)
    shadow.shadowBlurRadius = 70
    shadow.shadowOffset = NSSize(width: 0, height: -30)
    shadow.set()
    raw.draw(in: rect)
    NSGraphicsContext.current?.restoreGraphicsState()
}

/// The icon and header across the top, and the window below them,
/// with a second window, such as Settings, overlapping its corner.
func drawMac(copy: Copy, icon: Icon, raw: NSImage, extra: NSImage?, canvasSize: NSSize) {
    let textWidth = canvasSize.width - 240
    let header = Line(copy.header, size: 120, weight: .bold, color: .white, maxWidth: textWidth)
    let iconSize: CGFloat = 170
    let iconGap: CGFloat = 50
    let inkHeight = iconSize + iconGap + header.inkBottom - header.inkTop
    let textBand = inkHeight + 2 * 80
    let bottomMargin: CGFloat = 100

    // Captures are 2560 × 1600, a window of 1280 × 800 points at 2x.
    let windowHeight = canvasSize.height - textBand - bottomMargin
    let scale = windowHeight / raw.size.height
    let windowSize = NSSize(width: raw.size.width * scale, height: windowHeight)
    var windowRect = NSRect(
        x: ((canvasSize.width - windowSize.width) / 2).rounded(), y: bottomMargin,
        width: windowSize.width, height: windowSize.height
    )
    let extraSize = extra.map { NSSize(width: $0.size.width * scale, height: $0.size.height * scale) }
    if let extraSize {
        // Shifted left to make room for the second window on the right.
        windowRect.origin.x = ((canvasSize.width - windowSize.width - extraSize.width * 0.45) / 2).rounded()
    }

    let inkTop = (canvasSize.height + windowRect.maxY + inkHeight) / 2
    icon.draw(size: iconSize, top: inkTop.rounded(), canvasWidth: canvasSize.width)
    let headerTop = (inkTop - iconSize - iconGap + header.inkTop).rounded()
    header.draw(top: headerTop, canvasWidth: canvasSize.width)

    drawWindow(raw, in: windowRect)
    if let extra, let extraSize {
        let extraRect = NSRect(
            x: windowRect.maxX - extraSize.width * 0.55, y: windowRect.minY - bottomMargin * 0.5,
            width: extraSize.width, height: extraSize.height
        )
        drawWindow(extra, in: extraRect)
    }
}

// MARK: - Composition

func compose(_ shot: Screenshot, language: String, device: Device) -> Bool {
    guard let copy = shot.copy[language] else { return true }
    let rawURL = device.rawDir(language).appendingPathComponent("\(shot.name).png")
    guard let raw = NSImage(contentsOf: rawURL) else {
        print("missing raw capture: \(rawURL.path)")
        return false
    }

    let canvasSize = device.canvasSize
    let s = device.scale
    let image = NSImage(size: canvasSize)
    image.lockFocus()

    NSGradient(starting: gradientTop, ending: gradientBottom)?
        .draw(in: NSRect(origin: .zero, size: canvasSize), angle: -90)

    if device == .mac {
        let extra = NSImage(contentsOf: device.rawDir(language).appendingPathComponent("\(shot.name)-extra.png"))
        drawMac(copy: copy, icon: shot.icon, raw: raw, extra: extra, canvasSize: canvasSize)
        image.unlockFocus()
        return write(image, canvasSize: canvasSize, shot: shot, language: language, device: device)
    }

    // A one-line header. AppKit's origin is bottom-left.
    let textWidth = canvasSize.width - 96 * s
    let header = Line(copy.header, size: 84 * s, weight: .bold, color: .white, maxWidth: textWidth)
    let iconSize = 150 * s
    let iconGap = 44 * s
    // From the top of the icon to the bottom of the header's ink.
    let inkHeight = iconSize + iconGap + header.inkBottom - header.inkTop

    let aspect = deviceAspect(device)
    var deviceSize: NSSize
    let deviceBottom: CGFloat
    let deviceTop: CGFloat
    switch device {
    case .iPhone:
        // The device fills what is left below a band that holds the text.
        let textPadding = 80 * s
        let deviceBottomMargin = 80 * s
        deviceTop = canvasSize.height - inkHeight - 2 * textPadding
        let availableHeight = deviceTop - deviceBottomMargin
        deviceSize = NSSize(width: availableHeight * aspect, height: availableHeight)
        if deviceSize.width > canvasSize.width - 120 * s {
            deviceSize.width = canvasSize.width - 120 * s
            deviceSize.height = deviceSize.width / aspect
        }
        deviceBottom = deviceTop - deviceSize.height
    case .iPad, .mac:
        // The iPad is drawn as wide as the margins allow and runs off the bottom of the
        // canvas, leaving a band above it for the text.
        deviceSize = NSSize(width: canvasSize.width - 140 * s, height: (canvasSize.width - 140 * s) / aspect)
        deviceTop = canvasSize.height - 300 * s - iconSize - iconGap
        deviceBottom = deviceTop - deviceSize.height
    }

    // The icon and text are centered in the band between the top of the canvas and the device.
    let inkTop = (canvasSize.height + deviceTop + inkHeight) / 2
    shot.icon.draw(size: iconSize, top: inkTop.rounded(), canvasWidth: canvasSize.width)
    let headerTop = (inkTop - iconSize - iconGap + header.inkTop).rounded()
    header.draw(top: headerTop, canvasWidth: canvasSize.width)

    let deviceRect = NSRect(
        x: ((canvasSize.width - deviceSize.width) / 2).rounded(),
        y: deviceBottom.rounded(),
        width: deviceSize.width,
        height: deviceSize.height
    )

    switch device {
    case .iPhone:
        NSGraphicsContext.current?.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
        shadow.shadowBlurRadius = 60
        shadow.shadowOffset = NSSize(width: 0, height: -24)
        shadow.set()
        hardwareImage.draw(in: deviceRect)
        NSGraphicsContext.current?.restoreGraphicsState()
        maskedScreen(raw: raw).draw(in: deviceRect)
    case .iPad, .mac:
        drawiPad(raw: raw, in: deviceRect)
    }

    image.unlockFocus()
    return write(image, canvasSize: canvasSize, shot: shot, language: language, device: device)
}

/// Rasterizes at exactly the canvas size in pixels and writes it out.
func write(_ image: NSImage, canvasSize: NSSize, shot: Screenshot, language: String, device: Device) -> Bool {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize.width), pixelsHigh: Int(canvasSize.height),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
    ) else { return false }
    bitmap.size = canvasSize
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    image.draw(in: NSRect(origin: .zero, size: canvasSize))
    NSGraphicsContext.restoreGraphicsState()

    guard let png = bitmap.representation(using: .png, properties: [:]) else { return false }
    let outDir = device.outDir(language)
    try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
    let outURL = outDir.appendingPathComponent("\(shot.name).png")
    do {
        try png.write(to: outURL)
        print("wrote \(outURL.path.replacingOccurrences(of: scriptDir.path + "/", with: ""))")
        return true
    } catch {
        print("failed to write \(outURL.path): \(error)")
        return false
    }
}

var allOK = true
let sets: [(Device, [Screenshot])] = [(.iPhone, iPhoneScreenshots), (.iPad, iPadScreenshots), (.mac, macScreenshots)]
for language in languages {
    for (device, shots) in sets where device.isRequested {
        for shot in shots {
            allOK = compose(shot, language: language, device: device) && allOK
        }
    }
}
exit(allOK ? 0 : 1)
