import SwiftUI

struct SeasonPickerBar: View {
    let season: Season
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            seasonButton(systemName: "chevron.left", enabled: season.previous != nil, action: onPrevious)
            Text(String(season.year))
                .font(.headline.monospacedDigit())
                .frame(minWidth: 52)
            seasonButton(systemName: "chevron.right", enabled: season.next != nil, action: onNext)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private func seasonButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
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
    SeasonPickerBar(season: Season(year: 2026), onPrevious: {}, onNext: {})
        .padding()
}
