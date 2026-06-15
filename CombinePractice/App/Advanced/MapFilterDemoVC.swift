import Combine
import UIKit

final class MapFilterDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)
    private let subject = PassthroughSubject<Int, Never>()

    init() {
        super.init(title: "Map & Filter", description: "map 轉換、filter 過濾、compactMap 去除 nil。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("發送隨機數", for: .normal)
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        subject
            .map { $0 * 2 }
            .filter { $0 > 10 }
            .sink { [weak self] v in self?.eventLog.append("passed: \(v)") }
            .store(in: &cancellables)
    }

    @objc private func send() { subject.send(Int.random(in: 1...10)) }
}
