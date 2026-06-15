import Combine
import UIKit

final class MergeCombineLatestDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let buttonA = UIButton(type: .system)
    private let buttonB = UIButton(type: .system)
    private let scenariosButton = UIButton(type: .system)
    private let subjectA = PassthroughSubject<String, Never>()
    private let subjectB = PassthroughSubject<String, Never>()

    init() {
        super.init(
            title: "Merge & CombineLatest",
            description: """
            Merge：合併多條流，任一發出都往下傳。
            CombineLatest：每條流都要有值後，任一流更新都配對最新值輸出。
            建議：點 Send A / Send B 比較兩者 log 差異。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        buttonA.setTitle("Send A", for: .normal)
        buttonB.setTitle("Send B", for: .normal)
        scenariosButton.setTitle("常見使用情境 →", for: .normal)
        buttonA.addTarget(self, action: #selector(sendA), for: .touchUpInside)
        buttonB.addTarget(self, action: #selector(sendB), for: .touchUpInside)
        scenariosButton.addTarget(self, action: #selector(openScenarios), for: .touchUpInside)

        let sendStack = UIStackView(arrangedSubviews: [buttonA, buttonB])
        sendStack.axis = .horizontal
        sendStack.spacing = 12

        let stack = UIStackView(arrangedSubviews: [sendStack, scenariosButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        Publishers.Merge(subjectA, subjectB)
            .sink { [weak self] v in self?.eventLog.append("Merge: \(v)") }
            .store(in: &cancellables)
        subjectA.combineLatest(subjectB)
            .sink { [weak self] a, b in self?.eventLog.append("combineLatest: \(a) + \(b)") }
            .store(in: &cancellables)
    }

    @objc private func sendA() { subjectA.send("A\(Int.random(in: 1...9))") }
    @objc private func sendB() { subjectB.send("B\(Int.random(in: 1...9))") }

    @objc private func openScenarios() {
        navigationController?.pushViewController(MergeCombineLatestScenariosVC(), animated: true)
    }
}
