import SwiftUI

enum MatchDateTimeStyle {
    case full
    case timeOnly
}

struct MatchDateTimeLabel: View {
    let date: Date
    let venue: String
    var style: MatchDateTimeStyle = .full
    var font: Font = .subheadline
    var foregroundStyle: Color = .blue

    @State private var showsLocalTime = false

    private var venueTimeZone: TimeZone {
        VenueTimeZone.timeZone(for: venue)
    }

    private var displayTimeZone: TimeZone {
        showsLocalTime ? .current : venueTimeZone
    }

    private var formattedText: String {
        switch style {
        case .full:
            MatchDateFormatter.format(date, in: displayTimeZone)
        case .timeOnly:
            MatchDateFormatter.formatTime(date, in: displayTimeZone)
        }
    }

    var body: some View {
        Button {
            showsLocalTime.toggle()
        } label: {
            Text(formattedText)
                .font(font)
                .foregroundStyle(foregroundStyle)
        }
        .buttonStyle(.plain)
        .accessibilityHint(showsLocalTime ? "Shows your local time. Tap to show venue time." : "Shows venue time. Tap to show your local time.")
    }
}

#Preview {
    VStack(alignment: .leading) {
        MatchDateTimeLabel(
            date: Date(),
            venue: "Aspen, CO"
        )
        MatchDateTimeLabel(
            date: Date(),
            venue: "Belmar, NJ",
            font: .caption
        )
    }
    .padding()
}
