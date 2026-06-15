import Combine
import UIKit

final class ActionList2DemoVC: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    private let hintLabel = UILabel()
    private let fetchSourceLabel = UILabel()
    private let refreshButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)
    private let confirmMessageLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let errorLabel = UILabel()

    private let viewModel = ActionList2ViewModel(dependency: .init(fetchUsers: ListItemAPI.fetchUsers))

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Action List 2"
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
        hintLabel.text = """
        多觸發合流 + 確認帶狀態 → enum 要拆 bindFetch / bindConfirm。
        對照 List ViewModel：多 Input publisher + Merge 語意更清楚。
        """
        hintLabel.font = .systemFont(ofSize: 14)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0

        fetchSourceLabel.font = .systemFont(ofSize: 13)
        fetchSourceLabel.textColor = .tertiaryLabel
        fetchSourceLabel.numberOfLines = 0

        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        loadingIndicator.hidesWhenStopped = true
        refreshButton.setTitle("手動刷新", for: .normal)
        confirmButton.setTitle("確認選取", for: .normal)

        confirmMessageLabel.font = .systemFont(ofSize: 14)
        confirmMessageLabel.textColor = .secondaryLabel
        confirmMessageLabel.numberOfLines = 0
        confirmMessageLabel.text = "先選一筆，再按確認（withLatestFrom 帶選取狀態）"

        let buttonStack = UIStackView(arrangedSubviews: [refreshButton, confirmButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually

        let headerStack = UIStackView(arrangedSubviews: [
            hintLabel, fetchSourceLabel, errorLabel, loadingIndicator, buttonStack, confirmMessageLabel,
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

        confirmButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.action = .confirmSelection
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.viewModel.action = .willEnterForeground
            }
            .store(in: &cancellables)
    }

    private func bindViewModel() {
        viewModel.$viewObject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.errorLabel.text = message
                self?.errorLabel.isHidden = message == nil
            }
            .store(in: &cancellables)

        viewModel.$isConfirmEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.confirmButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)

        viewModel.$confirmMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let message else { return }
                self?.confirmMessageLabel.text = message
            }
            .store(in: &cancellables)

        viewModel.$lastFetchSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] source in
                guard let source else { return }
                self?.fetchSourceLabel.text = "上次 reload 觸發：\(source)"
            }
            .store(in: &cancellables)
    }
}

extension ActionList2DemoVC: UITableViewDataSource, UITableViewDelegate {
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

    // 選取改由 cell 內按鈕 / tapAreaView 觸發，不在 row 層級處理。
    // func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //     let viewObject = viewModel.viewObject[indexPath.row]
    //     viewModel.action = .selectItem(id: viewObject.id)
    // }
}
