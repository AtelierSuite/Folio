import SwiftUI

struct DayRingFace: View {
    let snapshot: LabSnapshot
    var bandWidth: CGFloat = 11
    var isMonochrome = false

    private func fraction(_ date: Date) -> Double {
        RingGeometry.fraction(of: date, from: snapshot.startOfToday)
    }

    private var halfBand: CGFloat { bandWidth / 2 }

    var body: some View {
        ZStack {
            RingArc(startFraction: 0, endFraction: 1, radiusInset: halfBand)
                .stroke(.quaternary, lineWidth: bandWidth)
            nightArc
            ForEach(RingGeometry.lanes(for: snapshot.eventsToday), id: \.event.id) { placed in
                RingArc(
                    startFraction: fraction(placed.event.start),
                    endFraction: fraction(placed.event.end),
                    radiusInset: halfBand + CGFloat(placed.lane) * (bandWidth * 0.6)
                )
                .stroke(isMonochrome ? AnyShapeStyle(.white) : AnyShapeStyle(placed.event.tint), lineWidth: placed.lane == 0 ? bandWidth : bandWidth * 0.5)
            }
            if !isMonochrome {
                sleepAndDoses
            }
            RingSpoke(fraction: fraction(snapshot.now), innerInset: bandWidth + 8, outerInset: -1)
                .stroke(isMonochrome ? Color.white : Color("AccentColor"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }

    @ViewBuilder
    private var nightArc: some View {
        if let weather = snapshot.weather(on: snapshot.now) {
            RingArc(startFraction: fraction(weather.sunset), endFraction: fraction(weather.sunrise) + 1, radiusInset: halfBand)
                .stroke(.indigo.opacity(isMonochrome ? 0.5 : 0.28), lineWidth: bandWidth)
        }
    }

    private var innerInset: CGFloat { bandWidth * 1.9 + 3 }

    @ViewBuilder
    private var sleepAndDoses: some View {
        if let sleep = snapshot.lastSleep {
            RingArc(startFraction: fraction(sleep.start), endFraction: fraction(sleep.end), radiusInset: innerInset)
                .stroke(.indigo, style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
        ForEach(snapshot.doses) { dose in
            RingSpoke(fraction: fraction(dose.time), innerInset: innerInset + 2, outerInset: innerInset - 2)
                .stroke(.teal, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
        }
    }
}
