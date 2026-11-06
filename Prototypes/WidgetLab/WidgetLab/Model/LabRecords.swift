import SwiftUI

struct LabReminder: Identifiable {
    var title: String
    var due: Date
    var tint: Color
    var id: String { title }
}

enum LabDoseStatus {
    case taken, skipped, notLogged, estimated
}

struct LabDose: Identifiable {
    var medication: String
    var amount: String
    var time: Date
    var recordedStatus: LabDoseStatus?
    var id: String { "\(medication)-\(time.timeIntervalSinceReferenceDate)" }

    func status(at now: Date) -> LabDoseStatus {
        if time > now { return .estimated }
        return recordedStatus ?? .notLogged
    }
}

struct LabWeather {
    var date: Date
    var symbol: String
    var condition: String
    var high: Int
    var low: Int
    var rainChance: Double
    var sunrise: Date
    var sunset: Date
}

struct LabHoliday {
    var date: Date
    var name: String
}
