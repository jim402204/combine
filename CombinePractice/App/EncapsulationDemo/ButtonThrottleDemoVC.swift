import Combine
import UIKit

final class ButtonThrottleDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)

    init() {
        super.init(
            title: "Button Throttle",
            description: """
            快速連點按鈕，觀察 onThrottle 如何限制觸發頻率（防止重複下單、重複送 API）。

            onThrottle 參數（PublisherThrottleSetting）：
            • seconds：時間窗口，預設 0.5 秒。窗口內多次點擊只放行部分事件。
            • isLatest：預設 false，窗口內取「第一下」；true 則取「最後一下」。
            • scheduler：計時排程器，預設 RunLoop.main。

            本頁使用預設值 onThrottle()，連點後 log 出現次數會少於實際點擊次數。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("連點我", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        button.publisher(for: .touchUpInside)
            .onThrottle()
            .sink { [weak self] in self?.eventLog.append("throttled tap") }
            .store(in: &cancellables)
    }
}
