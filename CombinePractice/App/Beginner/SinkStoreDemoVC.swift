import Combine
import UIKit

final class SinkStoreDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let subscribeButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private var tickCancellable: AnyCancellable?
    private var tick = 0

    init() {
        super.init(title: "Sink & Store", description: "點「開始訂閱」啟動計時，點「取消訂閱」停止。觀察 AnyCancellable 的生命週期。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        subscribeButton.setTitle("開始訂閱", for: .normal)
        cancelButton.setTitle("取消訂閱", for: .normal)
        let stack = UIStackView(arrangedSubviews: [subscribeButton, cancelButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        subscribeButton.addTarget(self, action: #selector(startSubscribe), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelSubscribe), for: .touchUpInside)
    }

    @objc private func startSubscribe() {
        tickCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.tick += 1
                self.eventLog.append("tick: \(self.tick)")
            }
        eventLog.append("已訂閱")
    }

    @objc private func cancelSubscribe() {
        tickCancellable?.cancel()
        tickCancellable = nil
        eventLog.append("已取消訂閱")
    }
}
