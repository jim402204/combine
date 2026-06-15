import Combine
import UIKit

final class MergeEventsDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let confirmButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let retryButton = UIButton(type: .system)

    init() {
        super.init(
            title: "Merge",
            description: """
            核心：多個同類型事件來源合併成一條流，任一按鈕觸發都走同一套處理。
            常見：確定 / 取消 / 重試按鈕、多個相同性質的通知來源。
            建議：依序點三顆按鈕，log 都從 Merge 這條鏈印出。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        confirmButton.setTitle("確定", for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        retryButton.setTitle("重試", for: .normal)

        let stack = UIStackView(arrangedSubviews: [confirmButton, cancelButton, retryButton])
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

        let confirm = confirmButton.publisher(for: .touchUpInside).map { "確定" }
        let cancel = cancelButton.publisher(for: .touchUpInside).map { "取消" }
        let retry = retryButton.publisher(for: .touchUpInside).map { "重試" }

        Publishers.Merge3(confirm, cancel, retry)
            .sink { [weak self] action in
                self?.eventLog.append("Merge 收到: \(action)")
            }
            .store(in: &cancellables)
    }
}
