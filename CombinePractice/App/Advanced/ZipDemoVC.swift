import Combine
import UIKit

final class ZipDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)
    private let subjectA = PassthroughSubject<Int, Never>()
    private let subjectB = PassthroughSubject<String, Never>()

    init() {
        super.init(
            title: "Zip",
            description: """
            zip：兩邊各發一次才配一對，按順序一對一（1 配 A、2 配 B）。
            combineLatest：兩邊都有值後，任一邊更新都配對最新值（1+A、2+A、2+B）。
            建議：按 Send Pair 觀察 zip 配對輸出。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("Send Pair", for: .normal)
        button.addTarget(self, action: #selector(sendPair), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        subjectA.zip(subjectB)
            .sink { [weak self] a, b in self?.eventLog.append("zip: \(a) + \(b)") }
            .store(in: &cancellables)
    }

    @objc private func sendPair() {
        let n = Int.random(in: 1...9)
        subjectA.send(n)
        subjectB.send("S\(n)")
    }
}
