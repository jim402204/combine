import Combine
import UIKit

final class ShareDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)

    init() {
        super.init(title: "Share", description: "share() 讓多個 sink 共用同一上游，避免重複執行。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("觸發上游", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        let shared = button.publisher(for: .touchUpInside)
            .handleEvents(receiveOutput: { [weak self] _ in self?.eventLog.append("upstream executed") })
            .share()
        shared.sink { [weak self] in self?.eventLog.append("subscriber 1") }.store(in: &cancellables)
        shared.sink { [weak self] in self?.eventLog.append("subscriber 2") }.store(in: &cancellables)
    }
}
