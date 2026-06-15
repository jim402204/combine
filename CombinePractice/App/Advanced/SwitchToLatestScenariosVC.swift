import UIKit

final class SwitchToLatestScenariosVC: UIViewController {
    private let descriptionText = """
    核心：篩選條件改變時，條件 A 的 API 結果不該在已選條件 B 後還更新畫面。
    switchToLatest 只保留「最新條件」的請求，舊的還沒回來就取消。

    1. 搜尋 UI — 關鍵字 A → B，A 的搜尋結果不該蓋過 B
    2. Segment 切換 — tab A → B，A 的列表結果不該蓋過 B
    3. 切換標的 — 標的 A → B，A 的資料不該蓋過 B

    點下方按鈕進入各情境互動 Demo。
    """

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "常見使用情境"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let descriptionLabel = UILabel()
        descriptionLabel.text = descriptionText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .secondaryLabel

        let searchButton = makeScenarioButton(title: "搜尋 UI", action: #selector(openSearch))
        let segmentButton = makeScenarioButton(title: "Segment 切換列表", action: #selector(openSegment))
        let targetButton = makeScenarioButton(title: "切換標的打 API", action: #selector(openTarget))

        let buttonStack = UIStackView(arrangedSubviews: [searchButton, segmentButton, targetButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 12
        buttonStack.alignment = .leading

        let stack = UIStackView(arrangedSubviews: [descriptionLabel, buttonStack])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func makeScenarioButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func openSearch() {
        navigationController?.pushViewController(SwitchToLatestSearchDemoVC(), animated: true)
    }

    @objc private func openSegment() {
        navigationController?.pushViewController(SwitchToLatestSegmentDemoVC(), animated: true)
    }

    @objc private func openTarget() {
        navigationController?.pushViewController(SwitchToLatestTargetDemoVC(), animated: true)
    }
}
