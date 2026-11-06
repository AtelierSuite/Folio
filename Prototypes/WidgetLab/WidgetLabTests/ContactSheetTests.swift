import SwiftUI
import Testing
@testable import WidgetLab

@MainActor
struct ContactSheetTests {
    private struct Condition {
        var name: String
        var scenario: LabScenario
        var minuteOfDay: Int
    }

    private let conditions = [
        Condition(name: "busy-1353", scenario: .busy, minuteOfDay: LabClock.defaultMinuteOfDay),
        Condition(name: "busy-0730", scenario: .busy, minuteOfDay: 450),
        Condition(name: "busy-2115", scenario: .busy, minuteOfDay: 1275),
        Condition(name: "light-1353", scenario: .light, minuteOfDay: LabClock.defaultMinuteOfDay),
        Condition(name: "empty-1353", scenario: .empty, minuteOfDay: LabClock.defaultMinuteOfDay)
    ]

    @Test func writesContactSheets() throws {
        let output = ProcessInfo.processInfo.environment["LAB_OUTPUT"] ?? NSTemporaryDirectory()
        let folder = URL(filePath: output)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let halves = [Array(LabIdea.catalog.prefix(5)), Array(LabIdea.catalog.suffix(5))]
        for condition in conditions {
            for scheme in [ColorScheme.light, .dark] where scheme == .light || condition.name == "busy-1353" {
                for (half, ideas) in halves.enumerated() {
                    let name = "\(condition.name)-\(scheme == .light ? "light" : "dark")-\(half + 1)"
                    let sheet = ContactSheet(
                        title: name,
                        ideas: ideas,
                        snapshot: condition.scenario.snapshot(minuteOfDay: condition.minuteOfDay)
                    )
                    .environment(\.colorScheme, scheme)
                    let renderer = ImageRenderer(content: sheet)
                    renderer.scale = 1.5
                    let image = try #require(renderer.uiImage)
                    let data = try #require(image.pngData())
                    try data.write(to: folder.appending(path: "\(name).png"))
                }
            }
        }
    }
}
