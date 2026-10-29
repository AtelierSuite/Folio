import Planner
import SwiftUI

extension AttendeeResponse {
    var title: String {
        switch self {
        case .accepted: String(localized: "Status.Accepted", table: "Invitations")
        case .tentative: String(localized: "Status.Maybe", table: "Invitations")
        case .declined: String(localized: "Status.Declined", table: "Invitations")
        case .pending: String(localized: "Status.Pending", table: "Invitations")
        }
    }

    var systemImage: String {
        switch self {
        case .accepted: "checkmark.circle.fill"
        case .tentative: "questionmark.circle.fill"
        case .declined: "xmark.circle.fill"
        case .pending: "circle.dashed"
        }
    }

    var tint: Color {
        switch self {
        case .accepted: .green
        case .tentative: .orange
        case .declined: .red
        case .pending: .secondary
        }
    }
}
