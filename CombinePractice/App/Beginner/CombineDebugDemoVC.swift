import Combine
import UIKit

final class CombineDebugDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let printButton = UIButton(type: .system)
    private let debugButton = UIButton(type: .system)
    private let handleEventsButton = UIButton(type: .system)
    private let trigger = PassthroughSubject<Int, Never>()

    init() {
        super.init(
            title: "Combine Debug",
            description: """
            三種常用 debug 方式（按鈕各示範一次）：
            1. print() — Combine 原生，自訂 label
            2. debug() — 專案封裝，label 自動帶檔名與行號
            3. handleEvents — 在鏈上插 log，適合寫進 eventLog
            詳細輸出請開 Xcode Console（Debug Area）；handleEvents 同時看畫面 eventLog。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        printButton.setTitle("1 · print()", for: .normal)
        debugButton.setTitle("2 · debug()", for: .normal)
        handleEventsButton.setTitle("3 · handleEvents", for: .normal)

        printButton.addTarget(self, action: #selector(runPrintDemo), for: .touchUpInside)
        debugButton.addTarget(self, action: #selector(runDebugDemo), for: .touchUpInside)
        handleEventsButton.addTarget(self, action: #selector(runHandleEventsDemo), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [printButton, debugButton, handleEventsButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
    }

    // MARK: - 1. print()：Combine 原生

    @objc private func runPrintDemo() {
        cancellables.removeAll()
        eventLog.append("── print() 示範 ──")
        eventLog.append("label 自己取，詳見 Xcode Console")

        trigger
            .print("trigger")
            .map { $0 * 2 }
            .print("after map")
            .filter { $0 > 10 }
            .print("after filter")
            .sink { [weak self] value in
                self?.eventLog.append("sink 收到: \(value)")
            }
            .store(in: &cancellables)

        trigger.send(3)
        trigger.send(8)
    }

    // MARK: - 2. debug()：專案封裝，帶檔名行號

    @objc private func runDebugDemo() {
        cancellables.removeAll()
        eventLog.append("── debug() 示範 ──")
        eventLog.append("Console label 含檔名、行號")

        trigger
            .debug("[debug]")
            .map { $0 * 2 }
            .debug("[after map]")
            .filter { $0 > 10 }
            .debug("[after filter]")
            .sink { [weak self] value in
                self?.eventLog.append("sink 收到: \(value)")
            }
            .store(in: &cancellables)

        trigger.send(3)
        trigger.send(8)
    }

    // MARK: - 3. handleEvents：畫面上看生命週期

    @objc private func runHandleEventsDemo() {
        cancellables.removeAll()
        eventLog.append("── handleEvents 示範 ──")

        trigger
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.eventLog.append("subscribed")
                },
                receiveOutput: { [weak self] value in
                    self?.eventLog.append("receiveOutput: \(value)")
                },
                receiveCompletion: { [weak self] _ in
                    self?.eventLog.append("completed")
                },
                receiveCancel: { [weak self] in
                    self?.eventLog.append("cancelled")
                }
            )
            .map { "×2 → \($0 * 2)" }
            .sink { [weak self] text in
                self?.eventLog.append("sink: \(text)")
            }
            .store(in: &cancellables)

        trigger.send(5)
    }
}
