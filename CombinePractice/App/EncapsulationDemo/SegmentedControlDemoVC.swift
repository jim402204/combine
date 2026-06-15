import Combine
import UIKit

final class SegmentedControlDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let segmented = UISegmentedControl(items: ["A", "B", "C"])

    init() {
        super.init(title: "Segmented Control", description: "selectedSegmentIndexPublisher() 已 removeDuplicates。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        segmented.selectedSegmentIndex = 0
        segmented.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(segmented)
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            segmented.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            segmented.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        segmented.selectedSegmentIndexPublisher()
            .sink { [weak self] index in self?.eventLog.append("selected index: \(index)") }
            .store(in: &cancellables)
    }
}
