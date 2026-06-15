import Combine
import UIKit

final class ActionList4DemoVC: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    private let hintLabel = UILabel()
    private let refreshButton = UIButton(type: .system)
    // fileprivate：供同檔案 Weak extension 更新 UI（private 無法被 Weak 存取）。
    fileprivate let tableView = UITableView(frame: .zero, style: .insetGrouped)
    fileprivate let loadingIndicator = UIActivityIndicatorView(style: .medium)
    fileprivate let errorLabel = UILabel()

    private let viewModel = ActionList4ViewModel(dependency: .init(fetchUsers: ListItemAPI.fetchUsers))

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Action List 4"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
        bindActions()
        viewModel.action = .viewDidLoad
    }

    private func setupLayout() {
        hintLabel.text = "Output 綁 UI 用 weak().present；cell 等邊角仍可用 [weak self]。"
        hintLabel.font = .systemFont(ofSize: 14)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0

        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        loadingIndicator.hidesWhenStopped = true
        refreshButton.setTitle("刷新列表", for: .normal)

        let headerStack = UIStackView(arrangedSubviews: [
            hintLabel, errorLabel, loadingIndicator, refreshButton,
        ])
        headerStack.axis = .vertical
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerStack)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func bindActions() {
        refreshButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.action = .refresh
            }
            .store(in: &cancellables)
    }

    private func bindViewModel() {
        viewModel.$viewObject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: weak().reloadTable)
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: weak().updateLoading)
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: weak().updateError)
            .store(in: &cancellables)
    }
}

extension ActionList4DemoVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.viewObject.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ListItemCell.reuseIdentifier,
            for: indexPath
        ) as! ListItemCell
        let viewObject = viewModel.viewObject[indexPath.row]
        cell.configure(with: viewObject)

        let itemID = viewObject.id
        cell.selectButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.action = .selectItem(id: itemID)
            }
            .store(in: &cell.reuseCancellables)

        cell.tapAreaView.tapPublisher()
            .sink { [weak self] _ in
                self?.viewModel.action = .selectItem(id: itemID)
            }
            .store(in: &cell.reuseCancellables)

        return cell
    }

}

extension ActionList4DemoVC: Compatible {}

private extension Weak where Base == ActionList4DemoVC {
    func reloadTable(_: [ListItemViewObject]) {
        guard let base else { return }
        base.tableView.reloadData()
    }

    func updateLoading(_ isLoading: Bool) {
        guard let base else { return }
        if isLoading {
            base.loadingIndicator.startAnimating()
        } else {
            base.loadingIndicator.stopAnimating()
        }
    }

    func updateError(_ message: String?) {
        guard let base else { return }
        base.errorLabel.text = message
        base.errorLabel.isHidden = message == nil
    }
}
