import Combine
import UIKit

final class ScanDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let textField = UITextField()
    private let limitLabel = UILabel()
    private let maxLength = 10

    init() {
        super.init(
            title: "Scan",
            description: """
            scan 會記住「上一次合法的狀態」。輸入文字時，超過字數上限就維持舊值，達到限制字數的效果。
            試著輸入超過 \(10) 個字，多打的字會被擋下來。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        textField.borderStyle = .roundedRect
        textField.placeholder = "最多 \(maxLength) 字"
        textField.clearButtonMode = .whileEditing

        limitLabel.font = .systemFont(ofSize: 14)
        limitLabel.textColor = .secondaryLabel
        limitLabel.text = "0/\(maxLength)"

        let stack = UIStackView(arrangedSubviews: [textField, limitLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        let limit = maxLength
        textField.publisher(for: .editingChanged)
            .map { [weak self] _ in self?.textField.text ?? "" }
            .scan("") { allowed, newText in
                newText.count <= limit ? newText : allowed
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] allowedText in
                guard let self else { return }
                if self.textField.text != allowedText {
                    self.textField.text = allowedText
                }
                self.limitLabel.text = "\(allowedText.count)/\(self.maxLength)"
                self.eventLog.append("scan 允許: \"\(allowedText)\"")
            }
            .store(in: &cancellables)
    }
}
