import Combine
import UIKit

extension UIView {
    private struct GesturePublisher: Publisher {
        typealias Output = GestureType
        typealias Failure = Never
        private weak var view: UIView?
        private let gestureType: GestureType

        init(view: UIView, gestureType: GestureType) {
            self.view = view
            self.gestureType = gestureType
        }

        func receive<S>(subscriber: S) where S: Subscriber,
            GesturePublisher.Failure == S.Failure, GesturePublisher.Output == S.Input {
            let subscription = GestureSubscription(
                subscriber: subscriber,
                view: view,
                gestureType: gestureType
            )
            subscriber.receive(subscription: subscription)
        }
    }

    private enum GestureType {
        case tap(UITapGestureRecognizer = .init())
        case longPress(UILongPressGestureRecognizer = .init())

        func get() -> UIGestureRecognizer {
            switch self {
            case let .tap(tapGesture): tapGesture
            case let .longPress(longPressGesture): longPressGesture
            }
        }
    }

    private final class GestureSubscription<S: Subscriber>: Subscription where S.Input == GestureType, S.Failure == Never {
        private var subscriber: S?
        private var gestureType: GestureType
        private weak var view: UIView?

        init(subscriber: S, view: UIView?, gestureType: GestureType) {
            self.subscriber = subscriber
            self.view = view
            self.gestureType = gestureType
            configureGesture(gestureType)
        }

        private func configureGesture(_ gestureType: GestureType) {
            let gesture = gestureType.get()
            gesture.addTarget(self, action: #selector(handler))
            view?.addGestureRecognizer(gesture)
        }

        func request(_: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
        }

        @objc private func handler() {
            _ = subscriber?.receive(gestureType)
        }
    }

    func tapPublisher(_ tapGesture: UITapGestureRecognizer = .init()) -> AnyPublisher<UITapGestureRecognizer, Never> {
        let gestureType = GestureType.tap(tapGesture)
        return GesturePublisher(view: self, gestureType: gestureType)
            .map { _ in tapGesture }
            .eraseToAnyPublisher()
    }

    func longPressPublisher(_ longPressGesture: UILongPressGestureRecognizer = .init()) -> AnyPublisher<UILongPressGestureRecognizer, Never> {
        let gestureType = GestureType.longPress(longPressGesture)
        return GesturePublisher(view: self, gestureType: gestureType)
            .map { _ in longPressGesture }
            .eraseToAnyPublisher()
    }
}
