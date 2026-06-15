import Combine
import UIKit

extension UIScrollView {
    func isReachBottomPublisher(offset: CGFloat = 0.001) -> AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(
            publisher(for: \.contentOffset).removeDuplicates(),
            publisher(for: \.contentSize).removeDuplicates()
        )
        .map { [weak self] _ -> Bool in
            self?.isReachBottom(offset: offset) ?? false
        }
        .eraseToAnyPublisher()
    }

    func isScrollingPublisher() -> AnyPublisher<Bool, Never> {
        let startScrollingPublisher = publisher(for: \.contentOffset)
            .map { _ in true }

        let endScrollingPublisher = publisher(for: \.contentOffset)
            .map { _ in () }
            .onThrottle()
            .map { _ in false }

        let gestureStatePublisher = panGestureRecognizer.publisher(for: \.state)
            .filter { $0 == .ended || $0 == .cancelled || $0 == .failed }
            .map { _ in false }

        return Publishers.Merge3(startScrollingPublisher, endScrollingPublisher, gestureStatePublisher)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
