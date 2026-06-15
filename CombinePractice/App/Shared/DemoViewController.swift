import UIKit

class DemoViewController: UIViewController {
    let descriptionText: String
    let eventLog = EventLogView()

    private let descriptionLabel = UILabel()
    let contentContainer = UIView()

    init(title: String, description: String) {
        self.descriptionText = description
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupDemoContent()
    }

    func setupDemoContent() {}

    private func setupLayout() {
        descriptionLabel.text = descriptionText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [descriptionLabel, contentContainer, eventLog])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            eventLog.heightAnchor.constraint(greaterThanOrEqualToConstant: 160),
        ])
    }
}
