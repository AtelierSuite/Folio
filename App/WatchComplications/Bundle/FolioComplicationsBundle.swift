import SwiftUI
import WidgetKit

@main
struct FolioComplicationsBundle: WidgetBundle {
    var body: some Widget {
        UpNextComplication()
        TimelineComplication()
        TodayComplication()
    }
}
