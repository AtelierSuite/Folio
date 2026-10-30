import Foundation
import Testing
@testable import Planner

struct NotificationStyleResolverTests {
    private let iPhone = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)
    private let mac = PlatformCapabilities(platform: .mac, areLiveActivitiesSupported: false)

    private func makeSettings() throws -> NotificationStyleSettings {
        let defaults = try #require(UserDefaults(suiteName: "NotificationStyleResolverTests.\(UUID().uuidString)"))
        return NotificationStyleSettings(defaults: defaults)
    }

    @Test func itemOverrideBeatsCalendarDefaultWhichBeatsTimeSensitive() throws {
        let settings = try makeSettings()
        let resolver = NotificationStyleResolver(settings: settings, capabilities: iPhone)
        let reference = Fixtures.reference(calendarIdentifier: "work")
        #expect(resolver.style(for: reference) == .timeSensitive)

        settings.setDefaultStyle(.standard, forCalendar: "work")
        #expect(resolver.style(for: reference) == .standard)
        #expect(resolver.style(for: Fixtures.reference(local: "other", calendarIdentifier: "home")) == .timeSensitive)

        settings.setStyleOverride(.alarm, for: reference)
        #expect(resolver.style(for: reference) == .alarm)

        settings.setStyleOverride(nil, for: reference)
        #expect(resolver.style(for: reference) == .standard)
    }

    @Test func overrideAppliesToEveryOccurrenceOfARecurringItem() throws {
        let settings = try makeSettings()
        let resolver = NotificationStyleResolver(settings: settings, capabilities: iPhone)
        let monday = Fixtures.reference(occurrence: Fixtures.date(2026, 11, 2, hour: 9))
        let tuesday = Fixtures.reference(occurrence: Fixtures.date(2026, 11, 3, hour: 9))
        settings.setStyleOverride(.alarm, for: monday)
        #expect(resolver.style(for: tuesday) == .alarm)
        #expect(resolver.style(for: Fixtures.reference(external: "external-2", local: "local-2")) == .timeSensitive)
    }

    @Test func macFallsBackFromAlarmToTimeSensitive() throws {
        let settings = try makeSettings()
        let reference = Fixtures.reference(calendarIdentifier: "work")
        settings.setDefaultStyle(.alarm, forCalendar: "work")
        let macResolver = NotificationStyleResolver(settings: settings, capabilities: mac)
        let iPhoneResolver = NotificationStyleResolver(settings: settings, capabilities: iPhone)
        #expect(macResolver.style(for: reference) == .timeSensitive)
        #expect(iPhoneResolver.style(for: reference) == .alarm)
    }

    @Test func availableStylesHideAlarmOnMac() {
        #expect(NotificationAlertStyle.available(on: iPhone) == [.standard, .timeSensitive, .alarm])
        #expect(NotificationAlertStyle.available(on: mac) == [.standard, .timeSensitive])
    }

    @Test func initialDefaultIsNotStored() throws {
        let defaults = try #require(UserDefaults(suiteName: "NotificationStyleResolverTests.\(UUID().uuidString)"))
        let settings = NotificationStyleSettings(defaults: defaults)
        settings.setDefaultStyle(.standard, forCalendar: "work")
        settings.setDefaultStyle(.timeSensitive, forCalendar: "work")
        #expect((defaults.dictionary(forKey: NotificationStyleSettings.calendarStylesKey) ?? [:]).isEmpty)
    }
}
