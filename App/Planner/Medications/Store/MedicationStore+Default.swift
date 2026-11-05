import Foundation

extension MedicationStore {
    public static func systemSource() -> (any MedicationDataSource)? {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(SampleMedicationDataSource.launchArgument) {
            return SampleMedicationDataSource()
        }
        #endif
        #if os(iOS)
        return HealthKitMedicationDataSource()
        #else
        return nil
        #endif
    }

    public convenience init(capabilities: PlatformCapabilities) {
        self.init(source: Self.systemSource(), capabilities: capabilities)
    }
}
