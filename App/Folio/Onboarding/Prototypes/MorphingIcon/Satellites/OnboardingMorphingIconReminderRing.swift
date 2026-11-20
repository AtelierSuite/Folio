import SwiftUI

struct OnboardingMorphingIconReminderRing: View {
    let beat: Int
    let unit: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    private static let checkColor = Color(red: 0.12, green: 0.68, blue: 0.47)
    private var count: Int { OnboardingMorphingIconRhythm.reminderCount }
    private var checked: Int {
        OnboardingMorphingIconRhythm.checkedReminders(atBeat: beat, reducesMotion: reducesMotion)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.secondary.opacity(0.15), lineWidth: 3 * unit)
            Circle()
                .trim(from: 0, to: Double(checked) / Double(count))
                .stroke(Self.checkColor, style: StrokeStyle(lineWidth: 3 * unit, lineCap: .round))
                .rotationEffect(.degrees(-90))
            ForEach(0..<count, id: \.self) { index in
                circle(isChecked: index < checked)
                    .offset(OnboardingMorphingIconGeometry.offset(
                        degrees: -90 + Double(index) * 360 / Double(count), radius: 118 * unit
                    ))
            }
        }
        .frame(width: 236 * unit, height: 236 * unit)
        .animation(.spring(duration: 0.45, bounce: 0.5), value: checked)
    }

    private func circle(isChecked: Bool) -> some View {
        ZStack {
            Circle().fill(.background)
            Circle().strokeBorder(.secondary.opacity(0.5), lineWidth: 2 * unit)
            Circle()
                .fill(Self.checkColor)
                .scaleEffect(isChecked ? 1 : 0.2)
                .opacity(isChecked ? 1 : 0)
            Image(systemName: "checkmark")
                .font(.system(size: 13 * unit, weight: .heavy))
                .foregroundStyle(.white)
                .scaleEffect(isChecked ? 1 : 0.3)
                .opacity(isChecked ? 1 : 0)
        }
        .frame(width: 30 * unit, height: 30 * unit)
        .scaleEffect(isChecked ? 1.08 : 1)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}
