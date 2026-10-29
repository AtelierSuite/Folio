import Planner

struct EventArrivalAlertChoice: Equatable {
    var original: Bool?
    var isOn = false

    var hasChanges: Bool {
        isOn != (original ?? false)
    }

    mutating func load(for reference: CalendarItemReference?, from arrivalAlerts: ArrivalAlertCenter) {
        guard original == nil else { return }
        let stored = reference.map(arrivalAlerts.isEnabled(for:)) ?? false
        original = stored
        isOn = stored
    }

    func save(for reference: CalendarItemReference, to arrivalAlerts: ArrivalAlertCenter) async {
        guard hasChanges else { return }
        await arrivalAlerts.setEnabled(isOn, for: reference)
    }
}
