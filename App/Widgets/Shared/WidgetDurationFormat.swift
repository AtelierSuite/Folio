import Foundation

enum WidgetDurationFormat {
    static func text(_ interval: TimeInterval) -> String {
        Duration.seconds(max(interval, 0))
            .formatted(.units(allowed: [.hours, .minutes], width: .narrow, zeroValueUnits: .hide))
    }
}
