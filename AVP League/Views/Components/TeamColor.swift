import SwiftUI

enum TeamColor {
    static func color(for team: AVPTeam) -> Color {
        switch team.id {
        case "nyn": .orange
        case "bb": .red
        case "lal": .purple
        case "sds": .blue
        case "pbp": .teal
        case "mm": .pink
        case "aa": .green
        case "dd": .indigo
        default: .gray
        }
    }
}
