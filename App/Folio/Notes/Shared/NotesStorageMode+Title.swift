import Foundation
import Planner

extension NotesStorageMode {
    func title(on platform: DevicePlatform) -> String {
        switch self {
        case .iCloudDrive:
            String(localized: "Storage.Mode.iCloudDrive", table: "Notes")
        case .onMyDevice:
            switch platform {
            case .iPhone: String(localized: "Storage.Mode.OnMyIPhone", table: "Notes")
            case .iPad: String(localized: "Storage.Mode.OnMyIPad", table: "Notes")
            case .mac: String(localized: "Storage.Mode.OnMyMac", table: "Notes")
            }
        case .customFolder:
            String(localized: "Storage.Mode.CustomFolder", table: "Notes")
        }
    }
}
