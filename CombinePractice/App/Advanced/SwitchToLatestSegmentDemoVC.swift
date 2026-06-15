import Combine
import UIKit

final class SwitchToLatestSegmentDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let segment = UISegmentedControl(items: ["台股", "美股", "債券"])
    private let tabs = ["台股", "美股", "債券"]

    init() {
        super.init(
            title: "Segment 切換",
            description: """
            核心：Segment 是篩選條件。從「台股」切到「美股」，台股的列表結果不該在已選美股後還更新畫面。
            建議：快速切換 台股 → 美股 → 債券，觀察舊 tab 的請求被取消。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(segment)
        NSLayoutConstraint.activate([
            segment.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            segment.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            segment.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            segment.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        segment.selectedSegmentIndexPublisher()
            .map { [tabs] index in tabs[index] }
            .map { [weak self] tab -> AnyPublisher<String, Never> in
                self?.eventLog.append("發送請求: 列表: \(tab)")
                return SwitchToLatestMockAPI.fetch(
                    label: "列表: \(tab)",
                    delay: 2,
                    onCancel: { [weak self] in
                        self?.eventLog.append("已取消舊請求: 列表: \(tab)")
                    }
                )
            }
            .switchToLatest()
            .sink { [weak self] value in self?.eventLog.append("結果: \(value)") }
            .store(in: &cancellables)
    }
}
