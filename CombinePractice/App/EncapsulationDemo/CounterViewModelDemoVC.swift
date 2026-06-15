import Combine
import UIKit

final class CounterViewModelDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let plusButton = UIButton(type: .system)
    private let minusButton = UIButton(type: .system)
    private let countLabel = UILabel()
    private let viewModel = CounterViewModel(dependency: .init(initialCount: 0))

    init() {
        super.init(title: "Counter ViewModel", description: "ViewModelType Input/Output 完整綁定流程。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        plusButton.setTitle("+", for: .normal)
        minusButton.setTitle("-", for: .normal)
        countLabel.font = .systemFont(ofSize: 24, weight: .bold)
        let stack = UIStackView(arrangedSubviews: [minusButton, countLabel, plusButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        let input = CounterViewModel.Input(
            didTapPlus: plusButton.publisher(for: .touchUpInside),
            didTapMinus: minusButton.publisher(for: .touchUpInside)
        )
        let output = viewModel.transform(from: input)
        output.countText.sinkOnMain(storeIn: &cancellables) { [weak self] text in
            self?.countLabel.text = text
            self?.eventLog.append(text)
        }
    }
}
