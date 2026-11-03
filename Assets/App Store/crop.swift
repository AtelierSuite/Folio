// Cuts a window out of a capture of the Mac VM's screen, with its rounded corners left transparent, as
// screencapture does for a window. The frame and corner radius are in points; the capture is at twice that.
// Usage: crop <screen.png> <window.png> <x> <y> <width> <height> <corner radius>
import AppKit

let arguments = CommandLine.arguments
guard arguments.count == 8,
      let screen = NSImage(contentsOfFile: arguments[1])?.cgImage(forProposedRect: nil, context: nil, hints: nil)
else {
    print("usage: crop <screen.png> <window.png> <x> <y> <width> <height> <corner radius>")
    exit(1)
}
let numbers = arguments[3...7].map { CGFloat(Double($0) ?? 0) }
let scale: CGFloat = 2
let frame = CGRect(x: numbers[0], y: numbers[1], width: numbers[2], height: numbers[3])
let pixels = CGRect(
    x: frame.minX * scale, y: frame.minY * scale, width: frame.width * scale, height: frame.height * scale
)
let radius = numbers[4] * scale

guard let window = screen.cropping(to: pixels),
      let context = CGContext(
          data: nil, width: window.width, height: window.height, bitsPerComponent: 8, bytesPerRow: 0,
          space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      )
else {
    print("the window is not on the screen")
    exit(1)
}
let bounds = CGRect(x: 0, y: 0, width: window.width, height: window.height)
context.addPath(CGPath(roundedRect: bounds, cornerWidth: radius, cornerHeight: radius, transform: nil))
context.clip()
context.draw(window, in: bounds)

guard let image = context.makeImage(),
      let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])
else { exit(1) }
try png.write(to: URL(fileURLWithPath: arguments[2]))
