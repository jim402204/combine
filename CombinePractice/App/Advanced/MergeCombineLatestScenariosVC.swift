import UIKit

final class MergeCombineLatestScenariosVC: UIViewController {
    private let descriptionText = """
    Merge 與 CombineLatest 解決不同問題：

    Merge — 多個「同類型事件」合併成一條流，任一來源觸發都走同一套處理。
    常見：多顆按鈕、多種刷新觸發、不同 UI map 成同類事件。

    CombineLatest — 多個 UI 元件各自有狀態，每個都要最新值才能算出同一個結果。
    常見：表單多欄位綁定按鈕 isEnabled（有輸入 + 已勾選同意才可按）。

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

        let mergeButtons = makeScenarioButton(title: "Merge — 多按鈕同類事件", action: #selector(openMergeButtons))
        let mergeRefresh = makeScenarioButton(title: "Merge — 多種刷新觸發", action: #selector(openMergeRefresh))
        let mergeMixedUI = makeScenarioButton(title: "Merge — 不同 UI 同類事件", action: #selector(openMergeMixedUI))
        let combineButton = makeScenarioButton(title: "CombineLatest — 按鈕 Enable", action: #selector(openCombineLatest))

        let buttonStack = UIStackView(arrangedSubviews: [mergeButtons, mergeRefresh, mergeMixedUI, combineButton])
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

    @objc private func openMergeButtons() {
        navigationController?.pushViewController(MergeEventsDemoVC(), animated: true)
    }

    @objc private func openMergeRefresh() {
        navigationController?.pushViewController(MergeRefreshTriggersDemoVC(), animated: true)
    }

    @objc private func openMergeMixedUI() {
        navigationController?.pushViewController(MergeMixedUISourcesDemoVC(), animated: true)
    }

    @objc private func openCombineLatest() {
        navigationController?.pushViewController(CombineLatestButtonEnableDemoVC(), animated: true)
    }
}
