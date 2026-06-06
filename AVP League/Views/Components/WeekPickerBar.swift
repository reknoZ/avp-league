import SwiftUI

struct WeekPickerBar: View {
    let week: ScheduleWeek
    let canGoPrevious: Bool
    let canGoNext: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            weekButton(systemName: "chevron.left", enabled: canGoPrevious, action: onPrevious)
            Text(week.title)
                .font(.headline.monospacedDigit())
                .frame(minWidth: 52)
            weekButton(systemName: "chevron.right", enabled: canGoNext, action: onNext)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private func weekButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.subheadline.weight(.semibold))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
        .foregroundStyle(enabled ? .primary : .tertiary)
        .disabled(!enabled)
    }
}

#Preview {
    WeekPickerBar(
        week: ScheduleWeek(number: 2, startDate: .now, endDate: .now),
        canGoPrevious: true,
        canGoNext: true,
        onPrevious: {},
        onNext: {}
    )
    .padding()
}
