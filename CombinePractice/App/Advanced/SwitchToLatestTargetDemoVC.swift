import Combine
import UIKit

final class SwitchToLatestTargetDemoVC: DemoViewController {
    private struct Target {
        let symbol: String
        let delay: TimeInterval
    }

    private var cancellables = Set<AnyCancellable>()
    private let triggerSubject = PassthroughSubject<Target, Never>()

    init() {
        super.init(
            title: "切換標的",
            description: """
            核心：標的是篩選條件。從 2330 切到 AAPL，2330 的 API 結果不該在已選 AAPL 後還更新畫面（flatMapLatest 典型情境）。
            2330 較慢（3 秒）、AAPL 較快（1 秒）。
            建議：先點 2330，3 秒內再點 AAPL，只會出現 AAPL 結果。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        let twButton = makeButton(title: "2330", action: #selector(selectTW))
        let usButton = makeButton(title: "AAPL", action: #selector(selectUS))
        let etfButton = makeButton(title: "0050", action: #selector(selectETF))

        let stack = UIStackView(arrangedSubviews: [twButton, usButton, etfButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        triggerSubject
            .map { [weak self] target -> AnyPublisher<String, Never> in
                self?.eventLog.append("發送請求: \(target.symbol)")
                return SwitchToLatestMockAPI.fetch(
                    label: target.symbol,
                    delay: target.delay,
                    onCancel: { [weak self] in
                        self?.eventLog.append("已取消舊請求: \(target.symbol)")
                    }
                )
            }
            .switchToLatest()
            .sink { [weak self] value in self?.eventLog.append("結果: \(value)") }
            .store(in: &cancellables)
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func selectTW() {
        triggerSubject.send(Target(symbol: "2330", delay: 3))
    }

    @objc private func selectUS() {
        triggerSubject.send(Target(symbol: "AAPL", delay: 1))
    }

    @objc private func selectETF() {
        triggerSubject.send(Target(symbol: "0050", delay: 2))
    }
}
