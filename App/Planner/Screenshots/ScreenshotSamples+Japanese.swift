#if DEBUG
import Foundation

extension ScreenshotSamples {
    static let japanese = ScreenshotSamples(
        calendars: [
            SampleCalendar(key: "arona", title: "アロナ", kind: .event, colorHex: 0x3D8BFF, alertStyle: .timeSensitive),
            SampleCalendar(key: "nagisa", title: "ナギサ", kind: .event, colorHex: 0xD9A441, alertStyle: .alarm),
            SampleCalendar(key: "hifumi", title: "ヒフミ", kind: .event, colorHex: 0xF06FA4, alertStyle: .standard),
            SampleCalendar(key: "saori", title: "サオリ", kind: .event, colorHex: 0x7E68C9, alertStyle: .alarm),
            SampleCalendar(
                key: "errands", title: "アロナに頼まれたこと", kind: .reminder, colorHex: 0x3D8BFF,
                alertStyle: .timeSensitive
            ),
            SampleCalendar(key: "study", title: "ヒフミと勉強", kind: .reminder, colorHex: 0xF06FA4, alertStyle: .standard),
            SampleCalendar(key: "supplies", title: "サオリへの物資", kind: .reminder, colorHex: 0x7E68C9, alertStyle: .alarm)
        ],
        events: japaneseEvents,
        reminders: japaneseReminders,
        notes: japaneseNotes,
        alarms: [
            SampleAlarm(hour: 6, minute: 30, label: "起床"),
            SampleAlarm(hour: 8, minute: 15, label: "3番教室へ出発"),
            SampleAlarm(hour: 12, minute: 45, label: "ロールケーキを受け取る"),
            SampleAlarm(hour: 16, minute: 40, label: "サオリに連絡")
        ],
        countdown: SampleCountdown(calendar: "nagisa", title: "ナギサとお茶", location: "5番教室", startsInMinutes: 24)
    )

    private static let japaneseEvents = [
        SampleEvent(calendar: "arona", title: "アロナと朝の打ち合わせ", day: 0, hour: 8, minute: 30, hours: 0.5),
        SampleEvent(calendar: "hifumi", title: "勉強会", day: 0, hour: 10, hours: 1.5, location: "3番教室"),
        SampleEvent(
            calendar: "nagisa", title: "ナギサとお茶", day: 0, hour: 13, hours: 1, location: "5番教室", alarmMinutes: [-15]
        ),
        SampleEvent(calendar: "nagisa", title: "ツルギとパトロール", day: 0, hour: 15, minute: 30, hours: 1.5),
        SampleEvent(calendar: "hifumi", title: "アズサと射撃訓練", day: 1, hour: 9, hours: 1),
        SampleEvent(
            calendar: "saori", title: "サオリと定例", day: 1, hour: 11, hours: 1, location: "8番教室", alarmMinutes: [-10]
        ),
        SampleEvent(calendar: "hifumi", title: "ヒフミとペロロ様探し", day: 1, hour: 14, hours: 1.5, location: "2番教室"),
        SampleEvent(calendar: "nagisa", title: "ミカと夕食", day: 1, hour: 18, minute: 30, hours: 1.5),
        SampleEvent(calendar: "arona", title: "アロナと朝の打ち合わせ", day: 2, hour: 8, minute: 30, hours: 0.5),
        SampleEvent(calendar: "nagisa", title: "サクラコと打ち合わせ", day: 2, hour: 10, hours: 1, location: "1番教室"),
        SampleEvent(calendar: "hifumi", title: "ハナコとランチ", day: 2, hour: 12, minute: 30, hours: 1),
        SampleEvent(calendar: "hifumi", title: "コハルの追試", day: 2, hour: 15, hours: 2),
        SampleEvent(
            calendar: "saori", title: "サオリと物資の買い出し", day: 3, hour: 9, minute: 30, hours: 2, location: "7番教室"
        ),
        SampleEvent(calendar: "nagisa", title: "セイアと庭園散歩", day: 3, hour: 13, hours: 1),
        SampleEvent(calendar: "nagisa", title: "マリーと夕べの祈り", day: 3, hour: 17, hours: 1),
        SampleEvent(calendar: "arona", title: "アロナと書類仕事", day: 4, hour: 9, hours: 2),
        SampleEvent(calendar: "saori", title: "アツコ、ミサキとピクニック", day: 4, hour: 12, hours: 1.5),
        SampleEvent(calendar: "nagisa", title: "お祭りの打ち合わせ", day: 4, hour: 15, hours: 1.5),
        SampleEvent(calendar: "saori", title: "ヒヨリと映画鑑賞", day: 4, hour: 19, hours: 2),
        SampleEvent(calendar: "nagisa", title: "ミカの誕生日", day: 2, hour: 0, hours: 24, isAllDay: true),
        SampleEvent(calendar: "arona", title: "アロナのお休み", day: 4, hour: 0, hours: 24, isAllDay: true)
    ]

    private static let japaneseReminders = [
        SampleReminder(list: "errands", title: "予算書にサイン", isCompleted: true),
        SampleReminder(list: "errands", title: "ナギサにロールケーキを注文", day: 0),
        SampleReminder(list: "errands", title: "アロナのタブレットを充電"),
        SampleReminder(list: "errands", title: "ユウカのメッセージに返信"),
        SampleReminder(list: "study", title: "模擬試験を印刷", isCompleted: true),
        SampleReminder(list: "study", title: "ヒフミにペロロ様のぬいぐるみを返す", day: 1, hour: 13),
        SampleReminder(list: "study", title: "3番教室を予約", day: 0, notes: "放課後"),
        SampleReminder(list: "study", title: "コハルの答案を採点", day: 2, hour: 10),
        SampleReminder(list: "study", title: "ごほうび用のペロロ様シール", notes: "ヒフミがお店を知っている"),
        SampleReminder(list: "study", title: "ハナコに作文のメモを借りる"),
        SampleReminder(list: "study", title: "夜の勉強会のおやつ", isCompleted: true),
        SampleReminder(list: "supplies", title: "サオリに物資リストを送る", day: 1),
        SampleReminder(list: "supplies", title: "アツコの救急キット"),
        SampleReminder(list: "supplies", title: "ミサキの予備マガジン"),
        SampleReminder(list: "supplies", title: "映画鑑賞のポップコーン", day: 2, hour: 18)
    ]
}
#endif
