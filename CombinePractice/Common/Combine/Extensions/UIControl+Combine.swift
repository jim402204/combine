import Combine
import UIKit

private struct UIControlPublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never

    private weak var control: UIControl?
    private let controlEvents: UIControl.Event

    init(control: UIControl, events: UIControl.Event) {
        self.control = control
        controlEvents = events
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}

private final class UIControlSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
    private var subscriber: S?
    private weak var control: UIControl?

    init(subscriber: S, control: UIControl?, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control?.addTarget(self, action: #selector(eventHandler), for: event)
    }

    func request(_: Subscribers.Demand) {}

    func cancel() {
        subscriber = nil
    }

    @objc private func eventHandler() {
        _ = subscriber?.receive()
    }
}

extension UIControl {
    func publisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
        UIControlPublisher(control: self, events: events).eraseToAnyPublisher()
    }
}
