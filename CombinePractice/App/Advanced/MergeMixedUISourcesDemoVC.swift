import Combine
import UIKit

final class MergeMixedUISourcesDemoVC: DemoViewController {
    private struct SubmitContext: Equatable {
        let productId: String
    }

    private enum UITriggerKind: String {
        case button
        case view
        case image
    }

    private var cancellables = Set<AnyCancellable>()
    private let productField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let tapAreaView = UIView()
    private let tapAreaLabel = UILabel()
    private let bannerImageView = UIImageView()
    private let contextSubject = CurrentValueSubject<SubmitContext, Never>(SubmitContext(productId: "2330"))

    init() {
        super.init(
            title: "Merge 多 UI",
            description: """
            核心：按鈕 / View / 圖片 → Merge → withLatestFrom 帶 block 同時取得觸發來源與最新商品。
            block 內 trigger 是誰點的、context 是當下商品代號；不帶 block 則只有 context。
            建議：改商品代號後，分別點三種 UI，觀察 log。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        productField.borderStyle = .roundedRect
        productField.placeholder = "商品代號（現有資料）"
        productField.text = "2330"

        submitButton.setTitle("提交按鈕", for: .normal)

        tapAreaView.backgroundColor = .secondarySystemBackground
        tapAreaView.layer.cornerRadius = 8
        tapAreaLabel.text = "點擊 View 區域"
        tapAreaLabel.font = .systemFont(ofSize: 14)
        tapAreaLabel.textColor = .secondaryLabel
        tapAreaLabel.translatesAutoresizingMaskIntoConstraints = false
        tapAreaView.addSubview(tapAreaLabel)

        bannerImageView.image = UIImage(systemName: "photo")
        bannerImageView.tintColor = .systemBlue
        bannerImageView.contentMode = .scaleAspectFit
        bannerImageView.backgroundColor = .tertiarySystemBackground
        bannerImageView.layer.cornerRadius = 8
        bannerImageView.clipsToBounds = true
        bannerImageView.isUserInteractionEnabled = true

        let stack = UIStackView(arrangedSubviews: [productField, submitButton, tapAreaView, bannerImageView])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            tapAreaView.heightAnchor.constraint(equalToConstant: 56),
            tapAreaLabel.centerXAnchor.constraint(equalTo: tapAreaView.centerXAnchor),
            tapAreaLabel.centerYAnchor.constraint(equalTo: tapAreaView.centerYAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 80),
        ])

        productField.publisher(for: .editingChanged)
            .map { [weak self] _ in self?.productField.text ?? "" }
            .map { SubmitContext(productId: $0.isEmpty ? "—" : $0) }
            .sink { [weak self] context in self?.contextSubject.send(context) }
            .store(in: &cancellables)

        let buttonTrigger = submitButton.publisher(for: .touchUpInside)
            .map { _ in UITriggerKind.button }
        let viewTrigger = tapAreaView.tapPublisher()
            .map { _ in UITriggerKind.view }
        let imageTrigger = bannerImageView.tapPublisher()
            .map { _ in UITriggerKind.image }

        Publishers.Merge3(buttonTrigger, viewTrigger, imageTrigger)
            .withLatestFrom(contextSubject) { trigger, context in
                // trigger：誰觸發（UITriggerKind）
                // context：觸發當下 contextSubject 的最新值
                return (trigger, context)
            }
            .sink { [weak self] trigger, context in
                self?.eventLog.append("觸發: \(trigger.rawValue) 商品: \(context.productId)")
            }
            .store(in: &cancellables)
    }
}
