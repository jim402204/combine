import Combine
import Foundation

enum SwitchToLatestMockAPI {
    static func fetch(
        label: String,
        delay: TimeInterval,
        onCancel: @escaping () -> Void
    ) -> AnyPublisher<String, Never> {
        Deferred {
            let subject = PassthroughSubject<String, Never>()
            var workItem: DispatchWorkItem?
            workItem = DispatchWorkItem {
                subject.send(label)
                subject.send(completion: .finished)
            }
            if let workItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
            }
            return subject
                .handleEvents(receiveCancel: {
                    workItem?.cancel()
                    onCancel()
                })
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
