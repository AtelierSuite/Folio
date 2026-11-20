import Testing
@testable import Planner

@MainActor
struct CoalescedRefreshTests {
    @MainActor
    private final class GatedWork {
        var runCount = 0
        var gate: CheckedContinuation<Void, Never>?

        func run() async {
            runCount += 1
            if runCount == 1 {
                await withCheckedContinuation { gate = $0 }
            }
        }
    }

    @Test func aBurstSharesOneExtraPass() async {
        let refresh = CoalescedRefresh()
        let work = GatedWork()
        let first = Task { await refresh.run(work.run) }
        while work.gate == nil {
            await Task.yield()
        }
        let burst = (0..<5).map { _ in Task { await refresh.run(work.run) } }
        for _ in 0..<20 {
            await Task.yield()
        }
        work.gate?.resume()
        await first.value
        for request in burst {
            await request.value
        }
        #expect(work.runCount == 2)
    }

    @Test func aLaterRequestRunsAgain() async {
        let refresh = CoalescedRefresh()
        var runCount = 0
        await refresh.run { runCount += 1 }
        await refresh.run { runCount += 1 }
        #expect(runCount == 2)
    }
}
