#if DEBUG
import Foundation

extension ScreenshotSamples {
    static let japanese = ScreenshotSamples(
        calendars: [
            SampleCalendar(key: "schale", title: "シャーレ", kind: .event, colorHex: 0x3D8BFF, alertStyle: .timeSensitive),
            SampleCalendar(key: "trinity", title: "トリニティ", kind: .event, colorHex: 0xD9A441, alertStyle: .alarm),
            SampleCalendar(key: "makeUp", title: "補習授業部", kind: .event, colorHex: 0xF06FA4, alertStyle: .standard),
            SampleCalendar(key: "arius", title: "アリウススクワッド", kind: .event, colorHex: 0x7E68C9, alertStyle: .alarm),
            SampleCalendar(
                key: "errands", title: "シャーレの用事", kind: .reminder, colorHex: 0x3D8BFF, alertStyle: .timeSensitive
            ),
            SampleCalendar(key: "study", title: "補習授業部", kind: .reminder, colorHex: 0xF06FA4, alertStyle: .standard),
            SampleCalendar(
                key: "supplies", title: "アリウスへの物資", kind: .reminder, colorHex: 0x7E68C9, alertStyle: .alarm
            )
        ],
        events: japaneseEvents,
        reminders: japaneseReminders,
        notes: japaneseNotes,
        alarms: [
            SampleAlarm(hour: 6, minute: 30, label: "起床"),
            SampleAlarm(hour: 8, minute: 15, label: "トリニティへ出発"),
            SampleAlarm(hour: 12, minute: 45, label: "ロールケーキを受け取る"),
            SampleAlarm(hour: 16, minute: 40, label: "サオリに連絡")
        ],
        countdown: SampleCountdown(
            calendar: "trinity", title: "ナギサとお茶会", location: "ティーパーティーのテラス", startsInMinutes: 24
        )
    )

    private static let japaneseEvents = [
        SampleEvent(calendar: "schale", title: "アロナと朝の打ち合わせ", day: 0, hour: 8, minute: 30, hours: 0.5),
        SampleEvent(calendar: "makeUp", title: "勉強会", day: 0, hour: 10, hours: 1.5, location: "トリニティ別館 3番教室"),
        SampleEvent(
            calendar: "trinity", title: "ナギサとお茶会", day: 0, hour: 13, hours: 1,
            location: "ティーパーティーのテラス", alarmMinutes: [-15]
        ),
        SampleEvent(calendar: "trinity", title: "ツルギとパトロール", day: 0, hour: 15, minute: 30, hours: 1.5),
        SampleEvent(calendar: "makeUp", title: "アズサと射撃訓練", day: 1, hour: 9, hours: 1),
        SampleEvent(
            calendar: "arius", title: "アリウススクワッドの定例", day: 1, hour: 11, hours: 1,
            location: "アリウス分校", alarmMinutes: [-10]
        ),
        SampleEvent(
            calendar: "makeUp", title: "ヒフミとペロロ様探し", day: 1, hour: 14, hours: 1.5, location: "トリニティ商店街"
        ),
        SampleEvent(calendar: "trinity", title: "ミカと夕食", day: 1, hour: 18, minute: 30, hours: 1.5),
        SampleEvent(calendar: "schale", title: "アロナと朝の打ち合わせ", day: 2, hour: 8, minute: 30, hours: 0.5),
        SampleEvent(calendar: "trinity", title: "シスターフッドの集会", day: 2, hour: 10, hours: 1, location: "トリニティ大聖堂"),
        SampleEvent(calendar: "makeUp", title: "ハナコとランチ", day: 2, hour: 12, minute: 30, hours: 1),
        SampleEvent(calendar: "makeUp", title: "コハルの追試", day: 2, hour: 15, hours: 2),
        SampleEvent(
            calendar: "arius", title: "サオリと物資の買い出し", day: 3, hour: 9, minute: 30, hours: 2, location: "アリウス自治区"
        ),
        SampleEvent(calendar: "trinity", title: "セイアと庭園散歩", day: 3, hour: 13, hours: 1),
        SampleEvent(calendar: "trinity", title: "マリーと夕べの祈り", day: 3, hour: 17, hours: 1),
        SampleEvent(calendar: "schale", title: "シャーレの書類仕事", day: 4, hour: 9, hours: 2),
        SampleEvent(calendar: "arius", title: "アリウススクワッドとピクニック", day: 4, hour: 12, hours: 1.5),
        SampleEvent(calendar: "trinity", title: "合同祭の打ち合わせ", day: 4, hour: 15, hours: 1.5),
        SampleEvent(calendar: "arius", title: "ヒヨリと映画鑑賞", day: 4, hour: 19, hours: 2),
        SampleEvent(calendar: "trinity", title: "ティーパーティー会談", day: 2, hour: 0, hours: 24, isAllDay: true),
        SampleEvent(calendar: "schale", title: "シッテムの箱のアップデート", day: 4, hour: 0, hours: 24, isAllDay: true)
    ]

    private static let japaneseReminders = [
        SampleReminder(list: "errands", title: "シャーレの予算書にサイン", isCompleted: true),
        SampleReminder(list: "errands", title: "お茶会のロールケーキを注文", day: 0),
        SampleReminder(list: "errands", title: "シッテムの箱を充電"),
        SampleReminder(list: "errands", title: "モモトークに返信"),
        SampleReminder(list: "study", title: "模擬試験を印刷", isCompleted: true),
        SampleReminder(list: "study", title: "ヒフミにペロロ様のぬいぐるみを返す", day: 1, hour: 13),
        SampleReminder(list: "study", title: "別館の教室を予約", day: 0, notes: "3番教室、放課後"),
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
