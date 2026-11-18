import Foundation
import Testing
@testable import Planner

struct AlarmSoundTests {
    @Test func offersTheSystemSoundAndTenOfFolios() {
        #expect(AlarmSound.allCases.count == 11)
        #expect(AlarmSound.allCases.first == .system)
        #expect(AlarmSound.system.fileName == nil)
        #expect(AlarmSound.kaminari.fileName == "Alarm-Kaminari.caf")
    }

    @Test func soundsAreStoredPerAlarmType() throws {
        let defaults = try #require(UserDefaults(suiteName: "AlarmSoundTests.\(UUID().uuidString)"))
        let wakeUp = WakeUpAlarmSettings(defaults: defaults)
        let leave = LeaveAlertSettings(defaults: defaults)
        #expect(wakeUp.sound == .system && leave.alarmSound == .system)
        wakeUp.sound = .hibari
        leave.alarmSound = .hayate
        #expect(WakeUpAlarmSettings(defaults: defaults).sound == .hibari)
        #expect(LeaveAlertSettings(defaults: defaults).alarmSound == .hayate)
    }

    /// Like the notification sounds, Default is stored as no value, so iCloud sync removes the choice elsewhere too.
    @Test func choosingDefaultClearsTheStoredSound() throws {
        let defaults = try #require(UserDefaults(suiteName: "AlarmSoundTests.\(UUID().uuidString)"))
        let wakeUp = WakeUpAlarmSettings(defaults: defaults)
        let leave = LeaveAlertSettings(defaults: defaults)
        wakeUp.sound = .hibari
        leave.alarmSound = .hayate
        wakeUp.sound = .system
        leave.alarmSound = .system
        #expect(defaults.object(forKey: WakeUpAlarmSettings.soundKey) == nil)
        #expect(defaults.object(forKey: LeaveAlertSettings.alarmSoundKey) == nil)
        #expect(wakeUp.sound == .system && leave.alarmSound == .system)
    }

    @Test func theSystemSoundKeepsTheIdentifierAndOthersChangeIt() {
        let plain = AlarmIdentifier.make(fromNotificationIdentifier: "wake")
        #expect(AlarmSound.system.alarmIdentifier(fromNotificationIdentifier: "wake") == plain)
        #expect(AlarmSound.hidamari.alarmIdentifier(fromNotificationIdentifier: "wake") != plain)
        #expect(AlarmSound.hidamari.alarmIdentifier(fromNotificationIdentifier: "wake")
                != AlarmSound.kaminari.alarmIdentifier(fromNotificationIdentifier: "wake"))
    }
}
