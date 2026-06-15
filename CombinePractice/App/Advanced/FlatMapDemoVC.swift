import Combine
import UIKit

final class FlatMapDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)

    init() {
        super.init(title: "FlatMap", description: "每次點擊 flatMap 至延遲 Publisher，模擬非同步請求。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("請求", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        button.publisher(for: .touchUpInside)
            .flatMap { _ -> AnyPublisher<String, Never> in
                let requestId = Int.random(in: 100...999)
                return Just("response-\(requestId)")
                    .delay(for: .seconds(1), scheduler: RunLoop.main)
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] value in self?.eventLog.append(value) }
            .store(in: &cancellables)
    }
}
