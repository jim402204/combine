import Combine
import UIKit

final class CombineLatestButtonEnableDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let nameField = UITextField()
    private let agreeSwitch = UISwitch()
    private let agreeLabel = UILabel()
    private let confirmButton = UIButton(type: .system)
    private let textSubject = CurrentValueSubject<String, Never>("")
    private let agreeSubject = CurrentValueSubject<Bool, Never>(false)

    init() {
        super.init(
            title: "CombineLatest",
            description: """
            核心：多個 UI 元件各自有狀態，每個都要最新值才能算出同一個結果。
            此例：姓名有輸入 且 同意條款 勾選 → 確定按鈕才可按（isEnabled）。
            建議：分別改姓名與開關，觀察按鈕 enable 與 log 同步變化。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        nameField.borderStyle = .roundedRect
        nameField.placeholder = "輸入姓名"

        agreeLabel.text = "同意條款"
        agreeLabel.font = .systemFont(ofSize: 15)

        confirmButton.setTitle("確定", for: .normal)
        confirmButton.isEnabled = false

        let switchRow = UIStackView(arrangedSubviews: [agreeSwitch, agreeLabel])
        switchRow.axis = .horizontal
        switchRow.spacing = 8
        switchRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [nameField, switchRow, confirmButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        nameField.publisher(for: .editingChanged)
            .map { [weak self] _ in self?.nameField.text ?? "" }
            .sink { [weak self] text in self?.textSubject.send(text) }
            .store(in: &cancellables)

        agreeSwitch.isOnPublisher()
            .sink { [weak self] isOn in self?.agreeSubject.send(isOn) }
            .store(in: &cancellables)

        textSubject.combineLatest(agreeSubject)
            .map { text, agreed in !text.isEmpty && agreed }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.confirmButton.isEnabled = isEnabled
                self?.eventLog.append("確定按鈕 isEnabled: \(isEnabled)")
            }
            .store(in: &cancellables)
    }
}
