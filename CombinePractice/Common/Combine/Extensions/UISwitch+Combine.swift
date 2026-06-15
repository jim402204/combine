import Combine
import UIKit

extension UISwitch {
    func isOnPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: .valueChanged)
            .map { [weak self] _ in
                self?.isOn ?? false
            }
            .eraseToAnyPublisher()
    }
}
