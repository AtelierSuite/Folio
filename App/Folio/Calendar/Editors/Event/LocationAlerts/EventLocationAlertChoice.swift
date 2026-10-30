import Planner

@MainActor
protocol EventLocationAlertToggling {
    func isEnabled(for reference: CalendarItemReference) -> Bool
    func setEnabled(_ isEnabled: Bool, for reference: CalendarItemReference) async
}

extension ArrivalAlertCenter: EventLocationAlertToggling {}
extension LeaveAlertCenter: EventLocationAlertToggling {}

struct EventLocationAlertChoice: Equatable {
    var original: Bool?
    var isOn = false

    var hasChanges: Bool {
        isOn != (original ?? false)
    }

    mutating func load(for reference: CalendarItemReference?, from alerts: some EventLocationAlertToggling) {
        guard original == nil else { return }
        let stored = reference.map(alerts.isEnabled(for:)) ?? false
        original = stored
        isOn = stored
    }

    func save(for reference: CalendarItemReference, to alerts: some EventLocationAlertToggling) async {
        guard hasChanges else { return }
        await alerts.setEnabled(isOn, for: reference)
    }
}
