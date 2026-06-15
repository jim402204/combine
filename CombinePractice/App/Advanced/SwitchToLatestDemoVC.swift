import Combine
import UIKit

final class SwitchToLatestDemoVC: DemoViewController {
    private struct Request {
        let label: String
        let delay: TimeInterval
    }

    private var cancellables = Set<AnyCancellable>()
    private let fastButton = UIButton(type: .system)
    private let slowButton = UIButton(type: .system)
    private let scenariosButton = UIButton(type: .system)
    private let triggerSubject = PassthroughSubject<Request, Never>()

    init() {
        super.init(
            title: "SwitchToLatest",
            description: """
            核心：條件改變時，舊條件的結果不該蓋過新條件。switchToLatest() 取消舊訂閱，只轉發最新請求的結果。
            建議：先按慢請求，3 秒內再按快請求 →「已取消舊請求: slow」→ 只有「結果: fast」。
            （RxSwift 同等語意叫 flatMapLatest。）
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        fastButton.setTitle("快請求", for: .normal)
        slowButton.setTitle("慢請求", for: .normal)
        scenariosButton.setTitle("常見使用情境 →", for: .normal)
        fastButton.addTarget(self, action: #selector(requestFast), for: .touchUpInside)
        slowButton.addTarget(self, action: #selector(requestSlow), for: .touchUpInside)
        scenariosButton.addTarget(self, action: #selector(openScenarios), for: .touchUpInside)

        let requestStack = UIStackView(arrangedSubviews: [fastButton, slowButton])
        requestStack.axis = .horizontal
        requestStack.spacing = 12

        let stack = UIStackView(arrangedSubviews: [requestStack, scenariosButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        triggerSubject
            .map { [weak self] request -> AnyPublisher<String, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return SwitchToLatestMockAPI.fetch(
                    label: request.label,
                    delay: request.delay,
                    onCancel: { [weak self] in
                        self?.eventLog.append("已取消舊請求: \(request.label)")
                    }
                )
            }
            .switchToLatest()
            .sink { [weak self] value in self?.eventLog.append("結果: \(value)") }
            .store(in: &cancellables)
    }

    @objc private func requestFast() {
        sendRequest(label: "fast", delay: 1)
    }

    @objc private func requestSlow() {
        sendRequest(label: "slow", delay: 3)
    }

    @objc private func openScenarios() {
        navigationController?.pushViewController(SwitchToLatestScenariosVC(), animated: true)
    }

    private func sendRequest(label: String, delay: TimeInterval) {
        eventLog.append("發送請求: \(label)")
        triggerSubject.send(Request(label: label, delay: delay))
    }
}
