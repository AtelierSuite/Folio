import Foundation

/// Reads today's open doses straight from Health for a widget, keeping them in memory like the app does.
/// Health can't be read while the device is locked, and then there is simply nothing to show.
public struct WidgetMedicationReader: Sendable {
    private let source: (any MedicationDataSource)?
    private let capabilities: PlatformCapabilities?
    private let calendar: Calendar

    public init(
        source: (any MedicationDataSource)? = MedicationStore.systemSource(),
        capabilities: PlatformCapabilities? = nil,
        calendar: Calendar = .current
    ) {
        self.source = source
        self.capabilities = capabilities
        self.calendar = calendar
    }

    /// Every dose today that isn't marked taken or skipped. Doses later today are included so the timeline
    /// can bring them in when they come due.
    public func dosesAwaitingAction(at now: Date) async -> [MedicationDose] {
        guard let source, await supportsMedications,
              let day = calendar.dateInterval(of: .day, for: now) else { return [] }
        let forecast = MedicationDoseForecast(calendar: calendar)
        do {
            let medications = Set(try await source.scheduledMedications())
            let records = try await source.doseRecords(in: Self.fetchInterval(around: day))
            let logged = MedicationDose.latest(from: records)
                .filter { day.contains($0.date) && medications.contains($0.medication) }
            let pastRecords = try await source.doseRecords(in: forecast.historyInterval(endingAt: now))
            let history = MedicationDose.latest(from: pastRecords)
                .filter { medications.contains($0.medication) }
            let loggedIdentifiers = Set(logged.map(\.id))
            let expected = forecast.doses(from: history, in: day, after: day.start)
                .filter { !loggedIdentifiers.contains($0.id) }
            return (expected + logged.filter { $0.status == .notLogged }).sorted { $0.date < $1.date }
        } catch {
            return []
        }
    }

    private var supportsMedications: Bool {
        get async {
            if let capabilities {
                return capabilities.supports(.medications)
            }
            return await PlatformCapabilities.current.supports(.medications)
        }
    }

    /// Doses are stored by when they were logged, which can be a day away from when they were due.
    private static func fetchInterval(around day: DateInterval) -> DateInterval {
        DateInterval(start: day.start.addingTimeInterval(-86_400), end: day.end.addingTimeInterval(86_400))
    }
}
