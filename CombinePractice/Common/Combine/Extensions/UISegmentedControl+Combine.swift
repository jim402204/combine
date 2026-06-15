import Combine
import UIKit

extension UISegmentedControl {
    func selectedSegmentIndexPublisher() -> AnyPublisher<Int, Never> {
        publisher(for: \.selectedSegmentIndex)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
