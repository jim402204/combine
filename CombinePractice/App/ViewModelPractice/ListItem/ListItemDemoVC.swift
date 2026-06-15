import Combine
import UIKit

final class ListItemDemoVC: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private var viewObjects: [ListItemViewObject] = []

    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let didSelectItemSubject = PassthroughSubject<Int, Never>()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let errorLabel = UILabel()

    private let viewModel = ListItemViewModel(dependency: .init(fetchUsers: ListItemAPI.fetchUsers))

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "List ViewModel"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
        viewDidLoadSubject.send()
    }

    private func setupLayout() {
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        loadingIndicator.hidesWhenStopped = true

        let headerStack = UIStackView(arrangedSubviews: [errorLabel, loadingIndicator])
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

    private func bindViewModel() {
        let input = ListItemViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            didSelectItem: didSelectItemSubject.eraseToAnyPublisher()
        )
        let output = viewModel.transform(from: input)

        output.items.sinkOnMain(storeIn: &cancellables) { [weak self] items in
            self?.viewObjects = items
            self?.tableView.reloadData()
        }

        output.isLoading.sinkOnMain(storeIn: &cancellables) { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }
        }

        output.errorMessage.sinkOnMain(storeIn: &cancellables) { [weak self] message in
            self?.errorLabel.text = message
            self?.errorLabel.isHidden = message == nil
        }
    }
}

extension ListItemDemoVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewObjects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ListItemCell.reuseIdentifier,
            for: indexPath
        ) as! ListItemCell
        let viewObject = viewObjects[indexPath.row]
        cell.configure(with: viewObject)

        let itemID = viewObject.id
        cell.selectButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.didSelectItemSubject.send(itemID)
            }
            .store(in: &cell.reuseCancellables)

        cell.tapAreaView.tapPublisher()
            .sink { [weak self] _ in
                self?.didSelectItemSubject.send(itemID)
            }
            .store(in: &cell.reuseCancellables)

        return cell
    }

    // 選取改由 cell 內按鈕 / tapAreaView 觸發，不在 row 層級處理。
    // func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //     let item = viewObjects[indexPath.row]
    //     didSelectItemSubject.send(item.id)
    // }
}
