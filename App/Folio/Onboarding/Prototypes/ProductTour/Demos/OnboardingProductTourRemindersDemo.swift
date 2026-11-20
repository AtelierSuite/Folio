import SwiftUI

struct OnboardingProductTourRemindersDemo: View {
    private static let beats: [OnboardingProductTourBeat] = [
        OnboardingProductTourBeat(.milliseconds(600), .easeOut(duration: 0.3)),
        OnboardingProductTourBeat(.milliseconds(350), .smooth(duration: 0.55)),
        OnboardingProductTourBeat(.milliseconds(650), .spring(duration: 0.35, bounce: 0.4)),
        OnboardingProductTourBeat(.milliseconds(250), .easeOut(duration: 0.2)),
        OnboardingProductTourBeat(.milliseconds(450), .smooth(duration: 0.6)),
        OnboardingProductTourBeat(.milliseconds(800), .spring(duration: 0.35, bounce: 0.4)),
        OnboardingProductTourBeat(.milliseconds(250), .easeOut(duration: 0.2)),
        OnboardingProductTourBeat(.milliseconds(450), .smooth(duration: 0.6)),
        OnboardingProductTourBeat(.milliseconds(500), .easeOut(duration: 0.3))
    ]

    var body: some View {
        OnboardingProductTourDemo(beats: Self.beats) { phase, canvas in
            OnboardingProductTourRemindersScene(phase: phase, canvas: canvas)
        }
    }
}

private struct OnboardingProductTourRemindersScene: View {
    private static let reminders: [(color: Color, titleWidth: CGFloat)] = [
        (.orange, 0.5), (.purple, 0.38), (.blue, 0.58), (.green, 0.44)
    ]
    private static let checkPhases = [3, 6]
    private static let donePhases = [5, 8]
    private static let rowHeight = OnboardingProductTourMetrics.reminderRowHeight
    private static let headerHeight = rowHeight * 0.75
    private static let circleSize: CGFloat = rowHeight * 0.42
    let phase: Int
    let canvas: OnboardingProductTourCanvas

    var body: some View {
        ZStack(alignment: .topLeading) {
            OnboardingProductTourAppScreen { Color.clear }
            Capsule()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 26, height: 4)
                .position(x: 10 + 13, y: doneHeaderY)
                .opacity(doneIndices.isEmpty ? 0 : 1)
            ForEach(Array(Self.reminders.enumerated()), id: \.offset) { index, reminder in
                OnboardingProductTourReminderRow(
                    color: reminder.color,
                    titleWidth: reminder.titleWidth,
                    circleSize: Self.circleSize,
                    isChecked: isChecked(index),
                    isDone: doneIndices.contains(index)
                )
                .frame(width: canvas.size.width, height: Self.rowHeight)
                .position(x: canvas.size.width / 2, y: rowY(for: index))
            }
            OnboardingProductTourFingertip(
                position: fingerPosition,
                isVisible: (1...8).contains(phase),
                isPressed: Self.checkPhases.contains(phase),
                tapCount: Self.checkPhases.filter { phase >= $0 }.count
            )
        }
    }

    private var listTop: CGFloat { canvas.contentTop + 4 }

    private var doneIndices: [Int] {
        Self.donePhases.enumerated().compactMap { index, donePhase in phase >= donePhase ? index : nil }
    }

    private var pendingIndices: [Int] {
        Self.reminders.indices.filter { !doneIndices.contains($0) }
    }

    private var doneHeaderY: CGFloat {
        listTop + Self.rowHeight * CGFloat(pendingIndices.count) + Self.headerHeight / 2 + 4
    }

    private func isChecked(_ index: Int) -> Bool {
        index < Self.checkPhases.count && phase >= Self.checkPhases[index]
    }

    private func rowY(for index: Int) -> CGFloat {
        if let slot = pendingIndices.firstIndex(of: index) {
            return listTop + Self.rowHeight * (CGFloat(slot) + 0.5)
        }
        let slot = doneIndices.firstIndex(of: index) ?? 0
        return doneHeaderY + Self.headerHeight / 2 + Self.rowHeight * (CGFloat(slot) + 0.5)
    }

    private var fingerPosition: CGPoint {
        let firstRowY = listTop + Self.rowHeight * 0.5
        if phase <= 1 {
            return CGPoint(x: canvas.size.width * 0.7, y: listTop + Self.rowHeight * 2.5)
        }
        return CGPoint(x: 12 + Self.circleSize / 2, y: firstRowY)
    }
}

private struct OnboardingProductTourReminderRow: View {
    let color: Color
    let titleWidth: CGFloat
    let circleSize: CGFloat
    let isChecked: Bool
    let isDone: Bool

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 7) {
                ZStack {
                    Circle()
                        .strokeBorder(isChecked ? color : Color.secondary.opacity(0.5), lineWidth: 1.5)
                    Circle()
                        .fill(color)
                        .scaleEffect(isChecked ? 1 : 0.2)
                        .opacity(isChecked ? 1 : 0)
                    Image(systemName: "checkmark")
                        .font(.system(size: circleSize * 0.55, weight: .black))
                        .foregroundStyle(.white)
                        .scaleEffect(isChecked ? 1 : 0.2)
                        .opacity(isChecked ? 1 : 0)
                }
                .frame(width: circleSize, height: circleSize)
                VStack(alignment: .leading, spacing: 3) {
                    Capsule()
                        .fill(Color.primary.opacity(isDone ? 0.25 : 0.75))
                        .frame(width: proxy.size.width * titleWidth, height: 4)
                    Capsule()
                        .fill(color.opacity(isDone ? 0.3 : 0.7))
                        .frame(width: proxy.size.width * titleWidth * 0.5, height: 3)
                }
                Spacer(minLength: 0)
            }
            .padding(.leading, 12)
            .frame(maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.primary.opacity(0.07))
                    .frame(height: 0.5)
                    .padding(.leading, 12 + circleSize + 7)
            }
        }
    }
}
