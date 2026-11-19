import Foundation
import Planner

extension DirectionsApp {
    var title: String {
        Bundle.main.localizedString(forKey: "App.\(id)", value: nil, table: "DefaultApps")
    }
}
