import Combine
import UIKit

final class DebounceThrottleDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)
    private let subject = PassthroughSubject<Void, Never>()

    init() {
        super.init(title: "Debounce & Throttle", description: "debounce 等靜止；throttle 固定間隔。連點比較差異。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("連點", for: .normal)
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        subject.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] in self?.eventLog.append("debounce fired") }
            .store(in: &cancellables)
        subject.throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: false)
            .sink { [weak self] in self?.eventLog.append("throttle fired") }
            .store(in: &cancellables)
    }

    @objc private func tap() { subject.send() }
}
