import Combine
import UIKit

enum DemoError: Error {
    case failed
    case timeout
}

final class CatchErrorDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let failButton = UIButton(type: .system)
    private let successButton = UIButton(type: .system)

    init() {
        super.init(title: "Catch Error", description: "失敗時 catch 改發 fallback 值。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        failButton.setTitle("觸發失敗", for: .normal)
        successButton.setTitle("觸發成功", for: .normal)
        failButton.addTarget(self, action: #selector(triggerFail), for: .touchUpInside)
        successButton.addTarget(self, action: #selector(triggerSuccess), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [failButton, successButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
    }

    @objc private func triggerFail() {
        Fail<String, DemoError>(error: .failed)
            .catch { _ in Just("fallback") }
            .sink { [weak self] value in self?.eventLog.append("result: \(value)") }
            .store(in: &cancellables)
    }

    @objc private func triggerSuccess() {
        Just("ok")
            .setFailureType(to: DemoError.self)
            .catch { _ in Just("fallback") }
            .sink { [weak self] value in self?.eventLog.append("result: \(value)") }
            .store(in: &cancellables)
    }
}
