import Foundation

extension CalendarStore {
    /// Floating events move to a new absolute time when the time zone changes, so cached results are stale.
    public func reloadAfterSystemTimeChange() async {
        await handleExternalChange()
    }
}
