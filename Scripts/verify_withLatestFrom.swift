import Combine
import Foundation

// MARK: - 與專案相同的精簡版實作（驗證用副本）

extension Publisher where Failure == Never {
    func withLatestFrom<Other: Publisher>(
        _ other: Other
    ) -> AnyPublisher<Other.Output, Never> where Other.Failure == Never {
        withLatestFrom(other) { _, latest in latest }
    }

    func withLatestFrom<Other: Publisher, Result>(
        _ other: Other,
        resultSelector: @escaping (Output, Other.Output) -> Result
    ) -> AnyPublisher<Result, Never> where Other.Failure == Never {
        let latest = CurrentValueSubject<Other.Output?, Never>(nil)
        var otherCancellable: AnyCancellable?

        return handleEvents(
            receiveSubscription: { _ in
                otherCancellable = other.sink { latest.send($0) }
            },
            receiveCancel: { otherCancellable?.cancel() }
        )
        .compactMap { output -> Result? in
            guard let value = latest.value else { return nil }
            return resultSelector(output, value)
        }
        .eraseToAnyPublisher()
    }

    func withLatestFrom<Other: Publisher, Other1: Publisher>(
        _ other: Other,
        _ other1: Other1
    ) -> AnyPublisher<(Other.Output, Other1.Output), Never>
    where Other.Failure == Never, Other1.Failure == Never {
        withLatestFrom(other, other1) { $1 }
    }

    func withLatestFrom<Other: Publisher, Other1: Publisher, Result>(
        _ other: Other,
        _ other1: Other1,
        resultSelector: @escaping (Output, (Other.Output, Other1.Output)) -> Result
    ) -> AnyPublisher<Result, Never>
    where Other.Failure == Never, Other1.Failure == Never {
        let combined = other.combineLatest(other1).eraseToAnyPublisher()
        return withLatestFrom(combined, resultSelector: resultSelector)
    }

    func withLatestFrom<Other: Publisher, Other1: Publisher, Other2: Publisher>(
        _ other: Other,
        _ other1: Other1,
        _ other2: Other2
    ) -> AnyPublisher<(Other.Output, Other1.Output, Other2.Output), Never>
    where Other.Failure == Never, Other1.Failure == Never, Other2.Failure == Never {
        withLatestFrom(other, other1, other2) { $1 }
    }

    func withLatestFrom<Other: Publisher, Other1: Publisher, Other2: Publisher, Result>(
        _ other: Other,
        _ other1: Other1,
        _ other2: Other2,
        resultSelector: @escaping (Output, (Other.Output, Other1.Output, Other2.Output)) -> Result
    ) -> AnyPublisher<Result, Never>
    where Other.Failure == Never, Other1.Failure == Never, Other2.Failure == Never {
        let combined = other.combineLatest(other1, other2).eraseToAnyPublisher()
        return withLatestFrom(combined, resultSelector: resultSelector)
    }
}

// MARK: - 簡易測試 harness

enum VerifyError: Error, CustomStringConvertible {
    case message(String)
    var description: String {
        switch self {
        case .message(let text): return text
        }
    }
}

final class Collector<T> {
    private(set) var values = [T]()
    private var cancellable: AnyCancellable?

    func bind<P: Publisher>(_ publisher: P) where P.Output == T, P.Failure == Never {
        cancellable = publisher.sink { [weak self] value in
            self?.values.append(value)
        }
    }
}

func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ name: String) throws {
    guard actual == expected else {
        throw VerifyError.message("\(name): 預期 \(expected)，實際 \(actual)")
    }
}

func waitUntil(_ condition: @escaping () -> Bool, timeout: TimeInterval = 1) throws {
    let deadline = Date().addingTimeInterval(timeout)
    while !condition() {
        if Date() > deadline {
            throw VerifyError.message("等待逾時")
        }
        RunLoop.current.run(until: Date().addingTimeInterval(0.01))
    }
}

func runTests() throws {
    // 1. source 更新不應單獨觸發
    do {
        let trigger = PassthroughSubject<Void, Never>()
        let source = CurrentValueSubject<String, Never>("A")
        let collector = Collector<String>()
        collector.bind(trigger.withLatestFrom(source))

        source.send("B")
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        try assertEqual(collector.values.count, 0, "source-only")

        trigger.send(())
        try waitUntil { collector.values.count == 1 }
        try assertEqual(collector.values[0], "B", "trigger 帶最新 source")
    }

    // 2. resultSelector 合併
    do {
        let trigger = PassthroughSubject<String, Never>()
        let source = CurrentValueSubject<Int, Never>(1)
        let collector = Collector<(String, Int)>()
        collector.bind(
            trigger.withLatestFrom(source) { trigger, latest in (trigger, latest) }
        )

        source.send(42)
        trigger.send("tap")
        try waitUntil { collector.values.count == 1 }
        try assertEqual(collector.values[0].0, "tap", "selector trigger")
        try assertEqual(collector.values[0].1, 42, "selector latest")
    }

    // 3. 多次 trigger 應拿到 source 當下最新值
    do {
        let trigger = PassthroughSubject<Void, Never>()
        let source = CurrentValueSubject<Int, Never>(0)
        let collector = Collector<Int>()
        collector.bind(trigger.withLatestFrom(source))

        source.send(1)
        trigger.send(())
        source.send(2)
        trigger.send(())
        try waitUntil { collector.values.count == 2 }
        try assertEqual(collector.values[0], 1, "first latest")
        try assertEqual(collector.values[1], 2, "second latest")
    }

    // 4. source 尚無值時 trigger 不應輸出
    do {
        let trigger = PassthroughSubject<Void, Never>()
        let source = PassthroughSubject<String, Never>()
        let collector = Collector<String>()
        collector.bind(trigger.withLatestFrom(source))

        trigger.send(())
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        try assertEqual(collector.values.count, 0, "no source yet")

        source.send("ready")
        trigger.send(())
        try waitUntil { collector.values.count == 1 }
        try assertEqual(collector.values[0], "ready", "after source ready")
    }

    // 5. 模擬 MergeMixedUISources：Merge trigger + contextSubject
    do {
        enum Trigger: String { case button, view }
        let button = PassthroughSubject<Void, Never>()
        let view = PassthroughSubject<Void, Never>()
        let context = CurrentValueSubject<String, Never>("p1")

        let merged = Publishers.Merge(
            button.map { Trigger.button },
            view.map { Trigger.view }
        )
        let collector = Collector<(Trigger, String)>()
        collector.bind(
            merged.withLatestFrom(context) { trigger, productId in (trigger, productId) }
        )

        context.send("p2")
        button.send(())
        try waitUntil { collector.values.count == 1 }
        try assertEqual(collector.values[0].0, .button, "merge trigger kind")
        try assertEqual(collector.values[0].1, "p2", "merge latest context")

        context.send("p9")
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        try assertEqual(collector.values.count, 1, "context-only no emit")
    }

    // 6. 模擬 ActionList confirm：CombineLatest context + filter trigger
    do {
        let items = CurrentValueSubject<[Int], Never>([1, 2, 3])
        let selected = CurrentValueSubject<Int?, Never>(2)
        let context = Publishers.CombineLatest(items, selected).eraseToAnyPublisher()

        let confirm = PassthroughSubject<Void, Never>()
        let collector = Collector<([Int], Int?)>()
        collector.bind(
            confirm.withLatestFrom(context) { _, ctx in ctx }
        )

        confirm.send(())
        try waitUntil { collector.values.count == 1 }
        try assertEqual(collector.values[0].0, [1, 2, 3], "confirm items")
        try assertEqual(collector.values[0].1, 2, "confirm selected")
    }

    // 7. 三 publisher overload
    do {
        let trigger = PassthroughSubject<Void, Never>()
        let a = CurrentValueSubject<Int, Never>(1)
        let b = CurrentValueSubject<Int, Never>(10)
        let collector = Collector<(Int, Int)>()
        collector.bind(trigger.withLatestFrom(a, b))

        a.send(2)
        b.send(20)
        trigger.send(())
        try waitUntil { collector.values.count == 1 }
        try assertEqual(collector.values[0].0, 2, "triple a")
        try assertEqual(collector.values[0].1, 20, "triple b")
    }

    // 8. 四 publisher overload
    do {
        let trigger = PassthroughSubject<Void, Never>()
        let a = CurrentValueSubject<Int, Never>(1)
        let b = CurrentValueSubject<Int, Never>(2)
        let c = CurrentValueSubject<Int, Never>(3)
        let collector = Collector<(Int, Int, Int)>()
        collector.bind(trigger.withLatestFrom(a, b, c))

        a.send(4)
        b.send(5)
        c.send(6)
        trigger.send(())
        try waitUntil { collector.values.count == 1 }
        try assertEqual(collector.values[0].0, 4, "quad a")
        try assertEqual(collector.values[0].1, 5, "quad b")
        try assertEqual(collector.values[0].2, 6, "quad c")
    }
}

do {
    try runTests()
    print("✅ withLatestFrom 精簡版驗證通過（8 項情境）")
} catch {
    fputs("❌ \(error)\n", stderr)
    exit(1)
}
