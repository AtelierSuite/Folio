import Foundation
import Testing
@testable import Planner

@MainActor
struct NotificationSoundFolderTests {
    private let root = FileManager.default.temporaryDirectory
        .appending(path: "NotificationSoundFolderTests-\(UUID().uuidString)", directoryHint: .isDirectory)

    private var bundleURL: URL { root.appending(path: "Bundle", directoryHint: .isDirectory) }
    private var soundsURL: URL { root.appending(path: "Sounds", directoryHint: .isDirectory) }

    private func makeFolder(defaults: UserDefaults) throws -> NotificationSoundFolder {
        try FileManager.default.createDirectory(at: bundleURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: soundsURL, withIntermediateDirectories: true)
        for sound in NotificationSoundLibrary.bundledSounds {
            try Data(sound.rawValue.utf8).write(to: bundleURL.appending(path: sound.fileName ?? ""))
        }
        return NotificationSoundFolder(defaults: defaults, sourceBundleURL: bundleURL, expectedFolderURL: soundsURL)
    }

    private func makeDefaults() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: "NotificationSoundFolderTests.\(UUID().uuidString)"))
    }

    @Test func staysUninstalledUntilTheFolderIsPicked() throws {
        let folder = try makeFolder(defaults: try makeDefaults())
        defer { try? FileManager.default.removeItem(at: root) }

        #expect(!folder.refresh())
    }

    @Test func refusesAnyFolderButTheSoundsFolder() throws {
        let defaults = try makeDefaults()
        let folder = try makeFolder(defaults: defaults)
        defer { try? FileManager.default.removeItem(at: root) }

        #expect(throws: NotificationSoundFolder.InstallError.wrongFolder) { try folder.install(into: bundleURL) }
        #expect(defaults.data(forKey: NotificationSoundFolder.bookmarkKey) == nil)
    }

    @Test func copiesEverySoundOncePickedAndRestoresDeletedOnes() throws {
        let folder = try makeFolder(defaults: try makeDefaults())
        defer { try? FileManager.default.removeItem(at: root) }

        try folder.install(into: soundsURL)
        #expect(folder.refresh())
        let furin = soundsURL.appending(path: "Calendar-Furin.caf")
        #expect(FileManager.default.fileExists(atPath: furin.path(percentEncoded: false)))

        try FileManager.default.removeItem(at: furin)
        #expect(folder.refresh())
        #expect(FileManager.default.fileExists(atPath: furin.path(percentEncoded: false)))
    }

    @Test func macUsesTheSystemSoundUntilSoundsAreInstalled() async throws {
        let defaults = try makeDefaults()
        let folder = try makeFolder(defaults: defaults)
        defer { try? FileManager.default.removeItem(at: root) }
        let center = FakeNotificationCenter()
        let settings = NotificationSettings(defaults: defaults)
        settings.isEnabled = true
        let scheduler = NotificationScheduler(
            source: FakeCalendarDataSource(
                events: [NotificationFixtures.event("work", start: NotificationFixtures.hours(1))],
                reminders: []
            ),
            center: center,
            alarmClient: FakeAlarmClient(authorization: .denied),
            alarmLedger: AlarmLedger(defaults: defaults),
            settings: settings,
            soundSettings: NotificationSoundSettings(defaults: defaults),
            soundFolder: folder,
            styleSettings: NotificationStyleSettings(defaults: defaults),
            allDayAlertTimeSettings: AllDayAlertTimeSettings(defaults: defaults),
            capabilities: PlatformCapabilities(platform: .mac, areLiveActivitiesSupported: false),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            clock: { NotificationFixtures.now }
        )

        await scheduler.setSound(.furin, for: .event)
        #expect(scheduler.needsSoundInstallation)
        #expect(center.pendingNotifications.map(\.sound) == [.system])

        try await scheduler.installSounds(into: soundsURL)
        #expect(!scheduler.needsSoundInstallation)
        #expect(center.pendingNotifications.map(\.sound) == [.furin])
    }
}
