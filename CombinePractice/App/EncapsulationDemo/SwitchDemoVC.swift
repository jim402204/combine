import Combine
import UIKit

final class SwitchDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let toggle = UISwitch()
    private let statusLabel = UILabel()

    init() {
        super.init(
            title: "Switch",
            description: """
            isOnPublisher() 將 UISwitch 事件轉為 Publisher。
            UI 更新用標準寫法：receive(on: DispatchQueue.main) + sink。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        statusLabel.text = "狀態：關"
        let stack = UIStackView(arrangedSubviews: [toggle, statusLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        toggle.isOnPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOn in
                self?.statusLabel.text = "狀態：\(isOn ? "開" : "關")"
                self?.eventLog.append("isOn: \(isOn)")
            }
            .store(in: &cancellables)
    }
}
