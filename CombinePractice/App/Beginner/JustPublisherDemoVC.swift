import Combine
import UIKit

final class JustPublisherDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let runButton = UIButton(type: .system)

    init() {
        super.init(title: "Just Publisher", description: "Just 與 Sequence 發出固定值，再經 map 轉換。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        runButton.setTitle("執行", for: .normal)
        runButton.addTarget(self, action: #selector(run), for: .touchUpInside)
        runButton.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(runButton)
        NSLayoutConstraint.activate([
            runButton.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            runButton.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            runButton.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
    }

    @objc private func run() {
        eventLog.clear()
        Just(3)
            .map { $0 * 10 }
            .sink { [weak self] value in self?.eventLog.append("Just result: \(value)") }
            .store(in: &cancellables)

        Publishers.Sequence(sequence: [1, 2, 3])
            .map { "item-\($0)" }
            .sink { [weak self] value in self?.eventLog.append("Sequence: \(value)") }
            .store(in: &cancellables)
    }
}
