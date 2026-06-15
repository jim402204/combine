import Combine
import UIKit

final class AssignVsSinkDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)
    private let sinkLabel = UILabel()
    private let assignLabel = UILabel()
    private let subject = CurrentValueSubject<String, Never>("")

    init() {
        super.init(
            title: "Assign vs Sink",
            description: """
            sink：在 closure 裡自己寫邏輯（改 UI、log、呼叫方法都行），彈性最大；要記得 [weak self]、receive(on: .main)。
            assign：直接把 Publisher 輸出綁到物件屬性（KeyPath），不用寫 closure，語意單純；適合「值 → 屬性」一對一更新。
            差異：要副作用或多步驟用 sink；只更新單一屬性、想寫法簡潔用 assign（型別要對得上，常搭配 map）。
            注意：assign 會強引用目標物件，目標先釋放可能 crash；VC 綁 UI 較常用 sink 或 assignOnMain。
            建議：按「更新」，比較兩個 label 與下方 log（只有 sink 會印 log）。
            """
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("更新", for: .normal)
        sinkLabel.text = "sink: -"
        assignLabel.text = "assign: -"
        button.addTarget(self, action: #selector(update), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [button, sinkLabel, assignLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        subject
            .sink { [weak self] value in
                self?.sinkLabel.text = "sink: \(value)"
                self?.eventLog.append("sink: \(value)")
            }
            .store(in: &cancellables)
        
        subject
            .map { "assign: \($0)" }
            .assign(to: \.text, on: assignLabel)
            .store(in: &cancellables)
    }

    @objc private func update() {
        subject.send("value-\(Int.random(in: 1...99))")
    }
}
