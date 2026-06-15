import Combine
import Foundation

extension Publisher {
    func onThrottle<S>(
        settings: PublisherThrottleSetting = .init(),
        scheduler: S = RunLoop.main
    ) -> Publishers.Throttle<Self, S> where S: Scheduler {
        throttle(for: .seconds(settings.seconds), scheduler: scheduler, latest: settings.isLatest)
    }

    func debug(
        _ prefix: String = "",
        file: String = #file,
        line: Int = #line,
        to stream: TextOutputStream? = nil
    ) -> Publishers.Print<Self> {
        print("\(prefix): \(URL(fileURLWithPath: file).lastPathComponent)-line:\(line)", to: stream)
    }
}

extension Publisher where Failure == Never {
    /// RxSwift `flatMapLatest` 對應寫法；語意同 Combine 原生 `switchToLatest()`。
    /// 注意：`flatMap(maxPublishers: .max(1))` 會在內層尚未完成時丟棄新事件，並不會取消舊訂閱。
    func flatMapLatest<P: Publisher>(
        _ transform: @escaping (Output) -> P
    ) -> AnyPublisher<P.Output, Failure> where P.Failure == Never {
        map(transform).switchToLatest().eraseToAnyPublisher()
    }

    func sinkOnMain(
        isRemoveDuplicates: Bool = true,
        storeIn cancellables: inout Set<AnyCancellable>,
        action: @escaping (Output) -> Void
    ) {
        let publisher: AnyPublisher<Output, Failure> = if isRemoveDuplicates, Output.self is any Equatable.Type {
            (self as? Publishers.RemoveDuplicates<Self>)?.eraseToAnyPublisher() ?? eraseToAnyPublisher()
        } else {
            eraseToAnyPublisher()
        }
        publisher.receive(on: DispatchQueue.main).sink { value in action(value) }.store(in: &cancellables)
    }

    func assignOnMain<Root>(
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on object: Root,
        isRemoveDuplicates: Bool = true,
        storeIn cancellables: inout Set<AnyCancellable>
    ) {
        let publisher: AnyPublisher<Output, Failure> = if isRemoveDuplicates, Output.self is any Equatable.Type {
            (self as? Publishers.RemoveDuplicates<Self>)?.eraseToAnyPublisher() ?? eraseToAnyPublisher()
        } else {
            eraseToAnyPublisher()
        }
        publisher.receive(on: DispatchQueue.main).assign(to: keyPath, on: object).store(in: &cancellables)
    }
}
