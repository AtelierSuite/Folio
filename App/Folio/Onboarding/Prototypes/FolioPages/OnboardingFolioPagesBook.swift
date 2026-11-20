import SwiftUI

struct OnboardingFolioPagesBook: View {
    let step: OnboardingStep
    let pageNumber: Int
    let features: [OnboardingFeature]
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var coverOpeningDate: Date?
    @State private var isCoverOpen = false
    @State private var turn: OnboardingFolioPagesTurn?

    private typealias Metrics = OnboardingFolioPagesMetrics

    var body: some View {
        TimelineView(.animation(paused: !isAnimating)) { timeline in
            layers(at: timeline.date)
        }
        .frame(width: Metrics.bookSize.width, height: Metrics.bookSize.height)
        .compositingGroup()
        .shadow(color: .black.opacity(0.22), radius: 16, y: 12)
        .onAppear(perform: openCover)
        .onChange(of: step) { oldStep, _ in
            turnPage(from: oldStep)
        }
        .accessibilityHidden(true)
    }

    private var isAnimating: Bool {
        turn != nil || (coverOpeningDate != nil && !isCoverOpen)
    }

    private func layers(at date: Date) -> some View {
        let turnProgress = turn?.progress(at: date)
        return ZStack(alignment: .topLeading) {
            OnboardingFolioPagesBoard()
            Group {
                OnboardingFolioPagesStack(count: pageNumber, arrival: turnProgress ?? 1)
                currentPage
                    .overlay { liftShadow(turnProgress: turnProgress) }
                if let turn, let turnProgress {
                    OnboardingFolioPagesTurningPage(step: turn.fromStep, features: features, progress: turnProgress)
                }
            }
            .padding(.leading, Metrics.pageOrigin.x)
            .padding(.top, Metrics.pageOrigin.y)
            let coverProgress = coverProgress(at: date)
            if coverProgress < 1 {
                OnboardingFolioPagesCover(progress: coverProgress)
            }
        }
    }

    private var currentPage: some View {
        OnboardingFolioPagesPage(
            step: step,
            features: features,
            animates: !reducesMotion,
            inkDelay: inkDelay
        )
        .id(step)
    }

    private var inkDelay: TimeInterval {
        if step == .welcome && !isCoverOpen {
            return Metrics.coverDelay + Metrics.coverDuration * 0.55
        }
        return Metrics.turnDuration * 0.4
    }

    private func liftShadow(turnProgress: Double?) -> some View {
        LinearGradient(
            colors: [.black.opacity(0.3), .black.opacity(0.08)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .opacity(turnProgress.map { 1 - $0 } ?? 0)
        .clipShape(OnboardingFolioPagesPaper.shape)
        .allowsHitTesting(false)
    }

    private func coverProgress(at date: Date) -> Double {
        if isCoverOpen { return 1 }
        guard let coverOpeningDate else { return 0 }
        let fraction = date.timeIntervalSince(coverOpeningDate) / Metrics.coverDuration
        return min(max(fraction, 0), 1)
    }

    private func openCover() {
        guard step == .welcome, !reducesMotion, coverOpeningDate == nil else {
            isCoverOpen = true
            return
        }
        coverOpeningDate = .now.addingTimeInterval(Metrics.coverDelay)
        Task {
            try? await Task.sleep(for: .seconds(Metrics.coverDelay + Metrics.coverDuration))
            isCoverOpen = true
        }
    }

    private func turnPage(from oldStep: OnboardingStep) {
        isCoverOpen = true
        guard !reducesMotion else { return }
        let newTurn = OnboardingFolioPagesTurn(fromStep: oldStep, startDate: .now)
        turn = newTurn
        Task {
            try? await Task.sleep(for: .seconds(Metrics.turnDuration))
            if turn == newTurn { turn = nil }
        }
    }
}

struct OnboardingFolioPagesTurn: Equatable {
    let fromStep: OnboardingStep
    let startDate: Date

    func progress(at date: Date) -> Double {
        let fraction = min(max(date.timeIntervalSince(startDate) / OnboardingFolioPagesMetrics.turnDuration, 0), 1)
        return fraction * fraction * (3 - 2 * fraction)
    }
}
