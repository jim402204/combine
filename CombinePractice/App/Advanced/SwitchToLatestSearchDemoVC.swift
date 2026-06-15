import Combine
import UIKit

final class SwitchToLatestSearchDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let textField = UITextField()

    init() {
        super.init(
            title: "搜尋 UI",
            description: """
            核心：關鍵字是篩選條件。從「台」改成「台積」，舊關鍵字的搜尋結果不該在已輸入新關鍵字後還更新畫面。
            debounce 減少請求次數；switchToLatest 確保只留最新條件的結果。
            建議：快速連續輸入，觀察舊關鍵字的請求被取消。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        textField.borderStyle = .roundedRect
        textField.placeholder = "輸入關鍵字"
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            textField.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        textField.publisher(for: .editingChanged)
            .map { [weak self] _ in self?.textField.text ?? "" }
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .map { [weak self] keyword -> AnyPublisher<String, Never> in
                self?.eventLog.append("發送搜尋: \(keyword)")
                return SwitchToLatestMockAPI.fetch(
                    label: "搜尋: \(keyword)",
                    delay: 1.5,
                    onCancel: { [weak self] in
                        self?.eventLog.append("已取消舊請求: 搜尋: \(keyword)")
                    }
                )
            }
            .switchToLatest()
            .sink { [weak self] value in self?.eventLog.append("結果: \(value)") }
            .store(in: &cancellables)
    }
}
