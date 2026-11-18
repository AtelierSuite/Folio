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
    case calendar, reminders, weather, map, ladybug
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
         base: .tinted(hex(0xF7F3EA), hex(0xECE5D3)), colors: [], keyline: .square, artwork: .map),
    Icon(name: "countdowns", glyph: .system("timer"),
         base: .tinted(hex(0x5DE07A), hex(0x24B04A)), colors: [white], keyline: .circle),
    Icon(name: "energyLevel", glyph: .system("bolt.fill"),
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
         base: .tinted(hex(0x9ED8FF), hex(0x4BA6F2)), colors: [], keyline: .circle, artwork: .ladybug)
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
    let dotRadius: CGFloat = 5
    let area = CGRect(x: Keyline.landscape.rect.minX, y: 50, width: Keyline.landscape.size.width,
                      height: Keyline.circle.rect.maxY - 50)
    let columns = (0..<4).map { area.minX + dotRadius + CGFloat($0) * (area.width - dotRadius * 2) / 3 }
    let rows = (0..<3).map { area.minY + dotRadius + CGFloat($0) * (area.height - dotRadius * 2) / 2 }
    return ZStack(alignment: .topLeading) {
        Rectangle()
            .fill(LinearGradient(colors: [hex(0xFF6259), hex(0xE5352B)].map { Color(nsColor: $0) },
                                 startPoint: .top, endPoint: .bottom))
            .frame(width: canvas, height: 38)
        ForEach(1..<11, id: \.self) { index in
            let center = CGPoint(x: columns[index % 4], y: rows[index / 4])
            if index == 6 {
                circle(calendarRed, center: center, radius: 11)
            } else {
                circle(quietGrey, center: center, radius: dotRadius)
            }
        }
    }
}

func reminderArtwork() -> some View {
    let square = Keyline.circle.rect
    let radius: CGFloat = 9.5
    let colors = [hex(0xFF9500), hex(0x007AFF), calendarRed]
    let lengths: [CGFloat] = [1, 0.78, 0.58]
    return ZStack(alignment: .topLeading) {
        ForEach(0..<3, id: \.self) { index in
            let center = CGPoint(x: square.minX + radius, y: square.minY + radius + CGFloat(index) * (square.height - radius * 2) / 2)
            if index == 0 {
                circle(colors[index], center: center, radius: radius)
                Path { path in
                    path.move(to: CGPoint(x: center.x - 5.4, y: center.y + 0.2))
                    path.addLine(to: CGPoint(x: center.x - 1.3, y: center.y + 4.3))
                    path.addLine(to: CGPoint(x: center.x + 6, y: center.y - 4.3))
                }
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3.8, lineCap: .round, lineJoin: .round))
            } else {
                ring(colors[index], center: center, radius: radius, lineWidth: 4)
            }
            let start = square.minX + radius * 2 + 10
            bar(quietGrey, CGRect(x: start, y: center.y - 4.5, width: (square.maxX - start) * lengths[index], height: 9))
        }
    }
}

func mapArtwork() -> some View {
    let pinWidth: CGFloat = 42
    let pinScale = pinWidth / 44
    let pin = { (x: CGFloat, y: CGFloat) in
        CGPoint(x: 60 + (x - 84) * pinScale, y: Keyline.circle.rect.minY + (y - 16) * pinScale)
    }
    let tip = pin(84, 72)
    let mainRoad = Path { path in
        path.move(to: CGPoint(x: -5, y: 84))
        path.addCurve(to: CGPoint(x: 125, y: 26), control1: CGPoint(x: 44, y: 80), control2: CGPoint(x: 78, y: 28))
    }
    let streets = Path { path in
        path.move(to: CGPoint(x: 92, y: -5))
        path.addLine(to: CGPoint(x: 92, y: 125))
        path.move(to: CGPoint(x: -5, y: 50))
        path.addLine(to: CGPoint(x: 125, y: 50))
    }
    return ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color(nsColor: hex(0xBFE0A0)))
            .frame(width: 52, height: 48)
            .offset(x: -10, y: -10)
        Path { path in
            path.move(to: CGPoint(x: -5, y: 100))
            path.addCurve(to: CGPoint(x: 125, y: 90), control1: CGPoint(x: 40, y: 88), control2: CGPoint(x: 80, y: 104))
            path.addLine(to: CGPoint(x: 125, y: 125))
            path.addLine(to: CGPoint(x: -5, y: 125))
            path.closeSubpath()
        }
        .fill(Color(nsColor: hex(0x8CCBF4)))
        streets.stroke(Color.white, lineWidth: 5)
        mainRoad.stroke(Color.white, lineWidth: 13)
        mainRoad.stroke(Color(nsColor: hex(0xFFC93C)), lineWidth: 8)
        Ellipse()
            .fill(Color.black.opacity(0.18))
            .frame(width: 22, height: 7)
            .offset(x: tip.x - 11, y: tip.y - 3.5)
        Path { path in
            path.move(to: pin(84, 16))
            path.addCurve(to: pin(62, 37), control1: pin(71, 16), control2: pin(62, 25))
            path.addCurve(to: tip, control1: pin(62, 52), control2: tip)
            path.addCurve(to: pin(106, 37), control1: tip, control2: pin(106, 52))
            path.addCurve(to: pin(84, 16), control1: pin(106, 25), control2: pin(97, 16))
            path.closeSubpath()
        }
        .fill(LinearGradient(colors: [hex(0xFF5A4F), hex(0xE0281E)].map { Color(nsColor: $0) },
                             startPoint: .top, endPoint: .bottom))
        circle(white, center: pin(84, 37), radius: 8 * pinScale)
    }
}

func ladybugWing(center: CGPoint, radius: CGFloat, side: CGFloat, angle: CGFloat) -> CGAffineTransform {
    let pivot = CGPoint(x: center.x, y: center.y - radius * 0.82)
    return CGAffineTransform(translationX: pivot.x, y: pivot.y)
        .rotated(by: -side * angle * .pi / 180)
        .translatedBy(x: -pivot.x, y: -pivot.y)
}

func ladybugArtwork() -> some View {
    let area = Keyline.circle.rect
    let headRadius: CGFloat = 15
    let bodyRadius: CGFloat = 29
    let antennaReach: CGFloat = 7
    let antennaTipRadius: CGFloat = 2.5
    let headToBody: CGFloat = 31
    let aboveHead = headRadius + antennaReach + antennaTipRadius
    let span = aboveHead + headToBody + bodyRadius
    let top = area.midY - span / 2
    let headCenter = CGPoint(x: area.midX, y: top + aboveHead)
    let bodyCenter = CGPoint(x: area.midX, y: headCenter.y + headToBody)
    let ink = hex(0x2C2C2E)
    let spots: [(CGPoint, CGFloat)] = [(CGPoint(x: -14, y: -8), 6.5), (CGPoint(x: -13, y: 13), 5)]
    let wingGradient = LinearGradient(colors: [hex(0xFF6B5E), hex(0xE5312A)].map { Color(nsColor: $0) },
                                      startPoint: .top, endPoint: .bottom)
    let openAngle: CGFloat = 14
    let spotCenters = [-1, 1].flatMap { (side: CGFloat) in
        spots.map { offset, radius in
            let transform = ladybugWing(center: bodyCenter, radius: bodyRadius, side: side, angle: openAngle)
            let center = CGPoint(x: bodyCenter.x - offset.x * side, y: bodyCenter.y + offset.y)
            return (center: center.applying(transform), radius: radius)
        }
    }
    return ZStack(alignment: .topLeading) {
        ForEach([-1, 1] as [CGFloat], id: \.self) { side in
            let tip = CGPoint(x: headCenter.x + side * 11, y: headCenter.y - headRadius - antennaReach)
            Path { path in
                path.move(to: CGPoint(x: headCenter.x + side * 4, y: headCenter.y - headRadius + 3))
                path.addLine(to: tip)
            }
            .stroke(Color(nsColor: ink), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            circle(ink, center: tip, radius: antennaTipRadius)
        }
        circle(ink, center: headCenter, radius: headRadius)
        circle(ink, center: bodyCenter, radius: bodyRadius - 1)
        ForEach([-1, 1] as [CGFloat], id: \.self) { side in
            Path { path in
                let points = (0...48).map { step in
                    let angle = (90 + CGFloat(step) * 180 / 48) * .pi / 180
                    return CGPoint(x: bodyCenter.x - side * cos(angle) * bodyRadius,
                                   y: bodyCenter.y + sin(angle) * bodyRadius)
                }
                path.addLines(points)
                path.closeSubpath()
            }
            .applying(ladybugWing(center: bodyCenter, radius: bodyRadius, side: side, angle: openAngle))
            .fill(wingGradient)
        }
        ForEach(0..<spotCenters.count, id: \.self) { index in
            circle(ink, center: spotCenters[index].center, radius: spotCenters[index].radius)
        }
    }
    .frame(width: canvas, height: canvas, alignment: .topLeading)
    .scaleEffect(min(1, area.height / span))
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
        case .map: mapArtwork()
        case .ladybug: ladybugArtwork()
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
