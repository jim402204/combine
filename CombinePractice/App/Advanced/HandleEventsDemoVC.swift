import Combine
import UIKit

final class HandleEventsDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)

    init() {
        super.init(title: "HandleEvents", description: "在 receiveOutput 做副作用（log / analytics）。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("執行", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        button.publisher(for: .touchUpInside)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.eventLog.append("subscribed") },
                receiveOutput: { [weak self] _ in self?.eventLog.append("receiveOutput") },
                receiveCompletion: { [weak self] _ in self?.eventLog.append("completed") },
                receiveCancel: { [weak self] in self?.eventLog.append("cancelled") }
            )
            .sink { _ in }
            .store(in: &cancellables)
    }
}
