import Planner
import SwiftUI

extension LocationKind {
    var systemImage: String {
        switch self {
        case .place: "mappin"
        case .food: "fork.knife"
        case .cafe: "cup.and.saucer.fill"
        case .drinks: "wineglass.fill"
        case .shopping: "bag.fill"
        case .groceries: "cart.fill"
        case .lodging: "bed.double.fill"
        case .airport: "airplane"
        case .transit: "tram.fill"
        case .car: "car.fill"
        case .fuel: "fuelpump.fill"
        case .charging: "bolt.fill"
        case .health: "cross.fill"
        case .education: "graduationcap.fill"
        case .nature: "tree.fill"
        case .water: "water.waves"
        case .culture: "building.columns.fill"
        case .entertainment: "theatermasks.fill"
        case .sports: "figure.run"
        case .finance: "banknote.fill"
        case .services: "building.2.fill"
        }
    }

    var color: Color {
        switch self {
        case .place: .red
        case .food, .cafe: .orange
        case .drinks: .purple
        case .shopping, .groceries: .yellow
        case .lodging: .indigo
        case .airport, .transit, .car, .fuel: .blue
        case .charging: .green
        case .health: .red
        case .education: .brown
        case .nature: .green
        case .water: .cyan
        case .culture, .entertainment: .pink
        case .sports: .mint
        case .finance, .services: .gray
        }
    }
}
