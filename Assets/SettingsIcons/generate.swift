// Generates the Settings category icons into App/Folio/Assets.xcassets/SettingsIcons.
// Run from the repository root: swift Assets/SettingsIcons/generate.swift [--guides <folder>]
import AppKit
import SwiftUI

let canvas: CGFloat = 120

enum Keyline {
    case circle, square, portrait, landscape

    var size: CGSize {
        switch self {
        case .circle: CGSize(width: 76, height: 76)
        case .square: CGSize(width: 68, height: 68)
        case .portrait: CGSize(width: 60, height: 80)
        case .landscape: CGSize(width: 80, height: 60)
        }
    }

    var rect: CGRect {
        CGRect(
            x: (canvas - size.width) / 2, y: (canvas - size.height) / 2,
            width: size.width, height: size.height
        )
    }
}

enum Base {
    case plain
    case tinted(NSColor, NSColor)

    var colors: (NSColor, NSColor) {
        switch self {
        case .plain: (hex(0xFFFFFF), hex(0xE9E9EE))
        case .tinted(let top, let bottom): (top, bottom)
        }
    }
}

enum Glyph {
    case system(String)
    case custom(String)
}

enum Artwork {
    case calendar, reminders, weather
}

struct Icon {
    let name: String
    let glyph: Glyph
    let base: Base
    let colors: [NSColor]
    let keyline: Keyline
    var multicolor = false
    var artwork: Artwork?
}

func hex(_ value: Int) -> NSColor {
    NSColor(
        srgbRed: CGFloat((value >> 16) & 0xFF) / 255,
        green: CGFloat((value >> 8) & 0xFF) / 255,
        blue: CGFloat(value & 0xFF) / 255,
        alpha: 1
    )
}

let white = hex(0xFFFFFF)
let graphite = hex(0x636366)

let icons: [Icon] = [
    Icon(name: "accounts", glyph: .system("person.fill"),
         base: .tinted(hex(0x5AB0FF), hex(0x1E6FE0)), colors: [white], keyline: .portrait),
    Icon(name: "general", glyph: .system("gearshape.fill"),
         base: .tinted(hex(0xA3A3AB), hex(0x6E6E76)), colors: [white], keyline: .circle),
    Icon(name: "calendars", glyph: .system("calendar"),
         base: .plain, colors: [], keyline: .square, artwork: .calendar),
    Icon(name: "reminders", glyph: .system("checklist"),
         base: .plain, colors: [], keyline: .square, artwork: .reminders),
    Icon(name: "alarms", glyph: .system("alarm.waves.left.and.right.fill"),
         base: .tinted(hex(0xFF7A70), hex(0xE0352B)), colors: [white], keyline: .landscape),
    Icon(name: "workWeek", glyph: .system("briefcase.fill"),
         base: .tinted(hex(0xC99A6B), hex(0x8E6239)), colors: [white], keyline: .landscape),
    Icon(name: "flexTime", glyph: .custom("flextime"),
         base: .tinted(hex(0x6BE3CF), hex(0x1FB59A)), colors: [white], keyline: .circle),
    Icon(name: "notes", glyph: .system("note.text"),
         base: .plain, colors: [graphite, hex(0xFFB800)], keyline: .square),
    Icon(name: "notifications", glyph: .system("bell.badge.fill"),
         base: .tinted(hex(0xFF6B8B), hex(0xE8305A)), colors: [hex(0xFFE14D), white], keyline: .portrait),
    Icon(name: "eventNotifications", glyph: .system("calendar.day.timeline.leading"),
         base: .tinted(hex(0xFF7A70), hex(0xE0352B)), colors: [white], keyline: .square),
    Icon(name: "birthdays", glyph: .system("party.popper.fill"),
         base: .tinted(hex(0x2E2A5C), hex(0x12102E)), colors: [hex(0xFFE14D), hex(0xFF7AC6)], keyline: .circle),
    Icon(name: "reminderNotifications", glyph: .system("checklist"),
         base: .tinted(hex(0xC08CFF), hex(0x8A3FE0)), colors: [hex(0xFFE14D), white], keyline: .square),
    Icon(name: "wakeUpAlarm", glyph: .system("alarm.fill"),
         base: .tinted(hex(0xFFB347), hex(0xFF5E62)), colors: [white], keyline: .circle),
    Icon(name: "travel", glyph: .system("map.fill"),
         base: .tinted(hex(0x5CB8FF), hex(0x2470E8)), colors: [white], keyline: .square),
    Icon(name: "countdowns", glyph: .system("timer"),
         base: .tinted(hex(0x5DE07A), hex(0x24B04A)), colors: [white], keyline: .circle),
    Icon(name: "focusLevel", glyph: .system("bolt.fill"),
         base: .tinted(hex(0xFFC14D), hex(0xFF8A00)), colors: [white], keyline: .portrait),
    Icon(name: "workouts", glyph: .system("figure.run"),
         base: .tinted(hex(0xD7F75B), hex(0xA5D610)), colors: [hex(0x1C1C1E)], keyline: .portrait),
    Icon(name: "sleep", glyph: .system("moon.stars.fill"),
         base: .tinted(hex(0x5B56D6), hex(0x1C1A5E)), colors: [hex(0xFFE27A), white], keyline: .circle),
    Icon(name: "medications", glyph: .system("pills.fill"),
         base: .tinted(hex(0x7FE0E0), hex(0x2AAFB8)), colors: [white, hex(0xFFE0DC)], keyline: .landscape),
    Icon(name: "weather", glyph: .system("cloud.fill"),
         base: .tinted(hex(0x5CC8FF), hex(0x2D8CF0)), colors: [white], keyline: .landscape, artwork: .weather),
    Icon(name: "search", glyph: .system("magnifyingglass"),
         base: .plain, colors: [graphite], keyline: .circle),
    Icon(name: "advanced", glyph: .system("slider.horizontal.3"),
         base: .tinted(hex(0xA3A3AB), hex(0x6E6E76)), colors: [white], keyline: .square),
    Icon(name: "debug", glyph: .system("ladybug.fill"),
         base: .tinted(hex(0x7AD957), hex(0x3E9E2C)), colors: [], keyline: .circle, multicolor: true)
]

let fileManager = FileManager.default
let root = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let catalog = root.appendingPathComponent("App/Folio/Assets.xcassets")
let output = catalog.appendingPathComponent("SettingsIcons")
let arguments = CommandLine.arguments
let guidesFolder = arguments.firstIndex(of: "--guides").map { URL(fileURLWithPath: arguments[$0 + 1]) }

func customSymbolBundle() -> Bundle {
    let folder = fileManager.temporaryDirectory.appendingPathComponent("SettingsIconSymbols-\(getpid())")
    let symbols = folder.appendingPathComponent("Symbols.xcassets")
    try? fileManager.createDirectory(at: symbols, withIntermediateDirectories: true)
    try? fileManager.copyItem(
        at: catalog.appendingPathComponent("flextime.symbolset"),
        to: symbols.appendingPathComponent("flextime.symbolset")
    )
    try? Data(#"{"info":{"author":"xcode","version":1}}"#.utf8)
        .write(to: symbols.appendingPathComponent("Contents.json"))
    let bundle = folder.appendingPathComponent("Symbols.bundle")
    let resources = bundle.appendingPathComponent("Contents/Resources")
    try? fileManager.createDirectory(at: resources, withIntermediateDirectories: true)
    let infoPlist: [String: String] = ["CFBundleIdentifier": "local.settings-icons", "CFBundlePackageType": "BNDL"]
    (infoPlist as NSDictionary).write(to: bundle.appendingPathComponent("Contents/Info.plist"), atomically: true)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    process.arguments = [
        "actool", symbols.path, "--compile", resources.path, "--platform", "macosx",
        "--minimum-deployment-target", "26.0", "--output-format", "human-readable-text"
    ]
    process.standardOutput = FileHandle.nullDevice
    try? process.run()
    process.waitUntilExit()
    return Bundle(url: bundle)!
}

let symbolBundle = customSymbolBundle()

func symbol(for icon: Icon) -> some View {
    let image = switch icon.glyph {
    case .system(let name): Image(systemName: name)
    case .custom(let name): Image(name, bundle: symbolBundle)
    }
    let colors = icon.colors.map { Color(nsColor: $0) }
    return Group {
        if icon.multicolor {
            image.resizable().symbolRenderingMode(.multicolor)
        } else if colors.count == 1 {
            image.resizable().symbolRenderingMode(.hierarchical).foregroundStyle(colors[0])
        } else {
            image.resizable().symbolRenderingMode(.palette).foregroundStyle(colors[0], colors[1])
        }
    }
    .fontWeight(.medium)
    .scaledToFit()
}

let measuringBox: CGFloat = 400

@MainActor
func inkBounds(of icon: Icon) -> CGRect {
    let renderer = ImageRenderer(content: symbol(for: icon).frame(width: measuringBox, height: measuringBox))
    let cgImage = renderer.cgImage!
    let width = cgImage.width, height = cgImage.height
    let context = CGContext(
        data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
        space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    let pixels = context.data!.assumingMemoryBound(to: UInt8.self)
    var minimumX = width, minimumRow = height, maximumX = -1, maximumRow = -1
    for row in 0..<height {
        for column in 0..<width where pixels[(row * width + column) * 4 + 3] > 24 {
            minimumX = min(minimumX, column)
            maximumX = max(maximumX, column)
            minimumRow = min(minimumRow, row)
            maximumRow = max(maximumRow, row)
        }
    }
    let scale = measuringBox / CGFloat(width)
    return CGRect(
        x: CGFloat(minimumX) * scale, y: CGFloat(minimumRow) * scale,
        width: CGFloat(maximumX - minimumX + 1) * scale, height: CGFloat(maximumRow - minimumRow + 1) * scale
    )
}

func baseView(_ base: Base) -> some View {
    let (top, bottom) = base.colors
    return LinearGradient(colors: [Color(nsColor: top), Color(nsColor: bottom)], startPoint: .top, endPoint: .bottom)
}

@MainActor
func fittedSymbol(_ icon: Icon, in target: CGRect) -> some View {
    let ink = inkBounds(of: icon)
    let scale = min(target.width / ink.width, target.height / ink.height)
    let box = measuringBox * scale
    return symbol(for: icon)
        .frame(width: box, height: box)
        .offset(x: target.midX - ink.width * scale / 2 - ink.minX * scale,
                y: target.midY - ink.height * scale / 2 - ink.minY * scale)
}

func circle(_ color: NSColor, center: CGPoint, radius: CGFloat) -> some View {
    Circle()
        .fill(Color(nsColor: color))
        .frame(width: radius * 2, height: radius * 2)
        .offset(x: center.x - radius, y: center.y - radius)
}

func ring(_ color: NSColor, center: CGPoint, radius: CGFloat, lineWidth: CGFloat) -> some View {
    Circle()
        .strokeBorder(Color(nsColor: color), lineWidth: lineWidth)
        .frame(width: radius * 2, height: radius * 2)
        .offset(x: center.x - radius, y: center.y - radius)
}

func bar(_ color: NSColor, _ rect: CGRect) -> some View {
    Capsule()
        .fill(Color(nsColor: color))
        .frame(width: rect.width, height: rect.height)
        .offset(x: rect.minX, y: rect.minY)
}

let calendarRed = hex(0xFF3B30)
let quietGrey = hex(0xC7C7CC)

func calendarArtwork() -> some View {
    let square = Keyline.square.rect
    let columns = (0..<4).map { square.minX + 4 + CGFloat($0) * 20 }
    let rows = (0..<3).map { square.maxY - 4 - CGFloat(2 - $0) * 18 }
    return ZStack(alignment: .topLeading) {
        Rectangle()
            .fill(LinearGradient(colors: [hex(0xFF6259), hex(0xE5352B)].map { Color(nsColor: $0) },
                                 startPoint: .top, endPoint: .bottom))
            .frame(width: canvas, height: 38)
        bar(white.withAlphaComponent(0.92), CGRect(x: Keyline.portrait.rect.minX + 8, y: 11, width: 8, height: 16))
        bar(white.withAlphaComponent(0.92), CGRect(x: Keyline.portrait.rect.maxX - 16, y: 11, width: 8, height: 16))
        ForEach(0..<12, id: \.self) { index in
            let center = CGPoint(x: columns[index % 4], y: rows[index / 4])
            if index == 6 {
                circle(calendarRed, center: center, radius: 9)
            } else {
                circle(quietGrey, center: center, radius: 4)
            }
        }
    }
}

func reminderArtwork() -> some View {
    let square = Keyline.square.rect
    let radius: CGFloat = 9.5
    let colors = [hex(0xFF9500), hex(0x007AFF), calendarRed]
    let lengths: [CGFloat] = [1, 0.78, 0.58]
    return ZStack(alignment: .topLeading) {
        ForEach(0..<3, id: \.self) { index in
            let center = CGPoint(x: square.minX + radius, y: square.minY + radius + CGFloat(index) * (square.height - radius * 2) / 2)
            if index == 0 {
                circle(colors[index], center: center, radius: radius)
                Path { path in
                    path.move(to: CGPoint(x: center.x - 4.4, y: center.y + 0.2))
                    path.addLine(to: CGPoint(x: center.x - 1, y: center.y + 3.6))
                    path.addLine(to: CGPoint(x: center.x + 5, y: center.y - 3.6))
                }
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round))
            } else {
                ring(colors[index], center: center, radius: radius, lineWidth: 3.4)
            }
            let start = square.minX + 28
            bar(quietGrey, CGRect(x: start, y: center.y - 3.5, width: (square.maxX - start) * lengths[index], height: 7))
        }
    }
}

@MainActor
func weatherArtwork(_ icon: Icon) -> some View {
    let sunRadius: CGFloat = 22
    let sunCenter = CGPoint(x: Keyline.landscape.rect.maxX - sunRadius, y: Keyline.circle.rect.minY + sunRadius)
    let square = Keyline.square.rect
    return ZStack(alignment: .topLeading) {
        circle(hex(0xFFD60A), center: sunCenter, radius: sunRadius)
        fittedSymbol(icon, in: CGRect(x: Keyline.landscape.rect.minX, y: square.maxY - 50, width: 72, height: 50))
    }
}

@MainActor
func iconView(_ icon: Icon) -> some View {
    ZStack(alignment: .topLeading) {
        baseView(icon.base)
        switch icon.artwork {
        case .calendar: calendarArtwork()
        case .reminders: reminderArtwork()
        case .weather: weatherArtwork(icon)
        case nil: fittedSymbol(icon, in: icon.keyline.rect)
        }
    }
    .frame(width: canvas, height: canvas, alignment: .topLeading)
}

func drawGuides(in context: CGContext) {
    context.setLineWidth(0.4)
    context.setStrokeColor(NSColor(srgbRed: 1, green: 0.1, blue: 0.6, alpha: 0.9).cgColor)
    context.stroke(CGRect(x: 0, y: 0, width: canvas, height: canvas).insetBy(dx: 0.2, dy: 0.2))
    context.move(to: CGPoint(x: 0, y: 0))
    context.addLine(to: CGPoint(x: canvas, y: canvas))
    context.move(to: CGPoint(x: 0, y: canvas))
    context.addLine(to: CGPoint(x: canvas, y: 0))
    context.move(to: CGPoint(x: canvas / 2, y: 0))
    context.addLine(to: CGPoint(x: canvas / 2, y: canvas))
    context.move(to: CGPoint(x: 0, y: canvas / 2))
    context.addLine(to: CGPoint(x: canvas, y: canvas / 2))
    context.strokePath()
    context.strokeEllipse(in: Keyline.circle.rect)
    context.strokeEllipse(in: Keyline.circle.rect.insetBy(dx: 22, dy: 22))
    context.stroke(Keyline.square.rect)
    context.stroke(Keyline.portrait.rect)
    context.stroke(Keyline.landscape.rect)
}

@MainActor
func render(_ icon: Icon, to url: URL, guides: Bool) {
    ImageRenderer(content: iconView(icon)).render { size, draw in
        var mediaBox = CGRect(origin: .zero, size: size)
        let context = CGContext(url as CFURL, mediaBox: &mediaBox, nil)!
        context.beginPDFPage(nil)
        draw(context)
        if guides { drawGuides(in: context) }
        context.endPDFPage()
        context.closePDF()
    }
    stripVolatileMetadata(at: url)
}

func stripVolatileMetadata(at url: URL) {
    guard var text = String(data: try! Data(contentsOf: url), encoding: .isoLatin1) else { return }
    for (pattern, replacement) in [
        (#"D:\d{14}Z00'00'"#, "D:20260101000000Z00'00'"),
        (#"<[0-9a-f]{32}>"#, "<" + String(repeating: "0", count: 32) + ">")
    ] {
        text = text.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
    }
    try! text.data(using: .isoLatin1)!.write(to: url)
}

func renderGrid(to url: URL) {
    var mediaBox = CGRect(x: 0, y: 0, width: canvas, height: canvas)
    let context = CGContext(url as CFURL, mediaBox: &mediaBox, nil)!
    context.beginPDFPage(nil)
    context.setFillColor(white.cgColor)
    context.fill(mediaBox)
    drawGuides(in: context)
    context.endPDFPage()
    context.closePDF()
    stripVolatileMetadata(at: url)
}

let contents = """
{
  "images" : [
    {
      "filename" : "%@.pdf",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "preserves-vector-representation" : true
  }
}

"""

try? fileManager.removeItem(at: output)
try! fileManager.createDirectory(at: output, withIntermediateDirectories: true)
try! Data(#"{"info":{"author":"xcode","version":1}}"#.utf8).write(to: output.appendingPathComponent("Contents.json"))

MainActor.assumeIsolated {
    for icon in icons {
        let asset = "Settings" + icon.name.prefix(1).uppercased() + icon.name.dropFirst()
        let folder = output.appendingPathComponent("\(asset).imageset")
        try! fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        render(icon, to: folder.appendingPathComponent("\(asset).pdf"), guides: false)
        try! Data(String(format: contents, asset).utf8).write(to: folder.appendingPathComponent("Contents.json"))
        if let guidesFolder {
            try? fileManager.createDirectory(at: guidesFolder, withIntermediateDirectories: true)
            render(icon, to: guidesFolder.appendingPathComponent("\(icon.name).pdf"), guides: true)
        }
    }
}

renderGrid(to: root.appendingPathComponent("Assets/SettingsIcons/Grid.pdf"))
print("Generated \(icons.count) icons")
