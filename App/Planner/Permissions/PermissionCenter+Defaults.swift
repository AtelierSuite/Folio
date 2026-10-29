import Foundation

extension PermissionCenter {
    public convenience init(calendarStore: CalendarStore, capabilities: PlatformCapabilities) {
        self.init(providers: Self.defaultProviders(calendarStore: calendarStore), capabilities: capabilities)
    }

    public static func defaultProviders(calendarStore: CalendarStore) -> [PermissionKind: any PermissionProvider] {
        [
            .calendar: CalendarPermissionProvider(store: calendarStore, kind: .event),
            .reminders: CalendarPermissionProvider(store: calendarStore, kind: .reminder),
            .notifications: NotificationPermissionProvider(),
            .location: LocationPermissionProvider()
        ]
    }
}
