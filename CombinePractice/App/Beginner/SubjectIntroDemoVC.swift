import Combine
import UIKit

final class SubjectIntroDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let passthroughButton = UIButton(type: .system)
    private let currentValueButton = UIButton(type: .system)
    private let passthroughSubject = PassthroughSubject<String, Never>()
    private let currentValueSubject = CurrentValueSubject<String, Never>("初始值")

    init() {
        super.init(title: "Subject 入門", description: "Passthrough 不保留值；CurrentValue 訂閱時立即拿到最新值。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        passthroughSubject.sink { [weak self] v in self?.eventLog.append("Passthrough: \(v)") }.store(in: &cancellables)
        currentValueSubject.sink { [weak self] v in self?.eventLog.append("CurrentValue: \(v)") }.store(in: &cancellables)
    }

    override func setupDemoContent() {
        passthroughButton.setTitle("Send Passthrough", for: .normal)
        currentValueButton.setTitle("Send CurrentValue", for: .normal)
        passthroughButton.addTarget(self, action: #selector(sendPassthrough), for: .touchUpInside)
        currentValueButton.addTarget(self, action: #selector(sendCurrentValue), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [passthroughButton, currentValueButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
    }

    @objc private func sendPassthrough() { passthroughSubject.send("事件 \(Int.random(in: 1...99))") }
    @objc private func sendCurrentValue() { currentValueSubject.send("更新 \(Int.random(in: 1...99))") }
}
