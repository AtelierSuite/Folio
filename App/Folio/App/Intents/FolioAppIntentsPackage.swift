import AppIntents
import Planner

struct FolioAppIntentsPackage: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] {
        [PlannerAppIntentsPackage.self]
    }
}
