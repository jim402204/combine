import Combine
import CombineExt
import UIKit

final class WithLatestFromDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let triggerButton = UIButton(type: .system)
    private let updateButton = UIButton(type: .system)
    private let trigger = PassthroughSubject<Void, Never>()
    private let source = CurrentValueSubject<String, Never>("初始")

    init() {
        super.init(title: "WithLatestFrom", description: "trigger 發生時，帶上 source 最新值（CombineExt）。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        triggerButton.setTitle("Trigger", for: .normal)
        updateButton.setTitle("Update Source", for: .normal)
        triggerButton.addTarget(self, action: #selector(fire), for: .touchUpInside)
        updateButton.addTarget(self, action: #selector(update), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [triggerButton, updateButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        trigger.withLatestFrom(source)
            .sink { [weak self] value in self?.eventLog.append("withLatestFrom: \(value)") }
            .store(in: &cancellables)
    }

    @objc private func fire() { trigger.send() }
    @objc private func update() { source.send("v\(Int.random(in: 1...99))") }
}
