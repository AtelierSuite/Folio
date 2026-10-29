import AppIntents
import Planner

struct FolioWidgetsAppIntentsPackage: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] {
        [PlannerAppIntentsPackage.self]
    }
}
