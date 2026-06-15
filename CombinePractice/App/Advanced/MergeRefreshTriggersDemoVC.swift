import Combine
import UIKit

final class MergeRefreshTriggersDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let scrollView = UIScrollView()
    private let refreshControl = UIRefreshControl()
    private let manualButton = UIButton(type: .system)
    private let placeholderLabel = UILabel()

    init() {
        super.init(
            title: "Merge 刷新",
            description: """
            核心：多種刷新觸發來源，合併後走同一個 reload。
            下拉刷新、背景回前景、手動刷新按鈕 → 同一條 Merge 鏈。
            建議：下拉列表、點手動刷新、或切到背景再回前景，觀察 reload 觸發來源。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        placeholderLabel.text = "下拉此區域刷新"
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.font = .systemFont(ofSize: 14)

        scrollView.refreshControl = refreshControl
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(placeholderLabel)

        manualButton.setTitle("手動刷新", for: .normal)
        manualButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [scrollView, manualButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 120),
            placeholderLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
        ])

        let pullToRefresh = refreshControl.publisher(for: .valueChanged).map { _ in "下拉刷新" }
        let foreground = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .map { _ in "背景回前景" }
        let manual = manualButton.publisher(for: .touchUpInside).map { _ in "手動刷新" }

        Publishers.Merge3(pullToRefresh, foreground, manual)
            .sink { [weak self] source in
                self?.refreshControl.endRefreshing()
                self?.eventLog.append("reload 觸發: \(source)")
                self?.eventLog.append("執行 reload…")
            }
            .store(in: &cancellables)
    }
}
