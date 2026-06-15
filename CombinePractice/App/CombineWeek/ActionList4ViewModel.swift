import Combine
import Foundation

final class ActionList4ViewModel {
    enum Action {
        case viewDidLoad
        case refresh
        case selectItem(id: Int)
    }

    private var cancellables = Set<AnyCancellable>()

    struct Dependency {
        let fetchUsers: () -> AnyPublisher<[ListItemModel], Error>
    }

    /// input
    @Published var action: Action? = nil
    /// output
    @Published var viewObject = [ListItemViewObject]()
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let dependency: Dependency

    // fileprivate：供同檔案 `extension Weak where Base == ActionList4ViewModel` 透過 base 存取。
    // private 僅限型別內部，Weak 是另一個型別，即使在同檔案也無法讀取 private 成員。
    fileprivate let itemsSubject = CurrentValueSubject<[ListItemModel], Never>([])
    fileprivate let selectedIDSubject = CurrentValueSubject<Int?, Never>(nil)

    init(dependency: Dependency) {
        self.dependency = dependency
        binding()
    }

    func binding() {
        $action
            .compactMap { $0 }
            .sink(receiveValue: weak().handle)
            .store(in: &cancellables)

        Publishers.CombineLatest(itemsSubject, selectedIDSubject)
            .map { models, selectedID in
                models.map { model in
                    ListItemViewObject(
                        id: model.id,
                        title: model.name,
                        subtitle: model.email,
                        isSelected: model.id == selectedID
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: weak().updateViewObject)
            .store(in: &cancellables)
    }

    // fileprivate：供 Weak extension 的 handle 觸發 fetch。
    fileprivate func fetchUsers() {
        isLoading = true
        errorMessage = nil

        dependency.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: weak().handleFetchCompletion,
                receiveValue: weak().handleFetchModels
            )
            .store(in: &cancellables)
    }
}

extension ActionList4ViewModel: Compatible {}

private extension Weak where Base == ActionList4ViewModel {
    func handle(_ action: ActionList4ViewModel.Action) {
        guard let base else { return }
        switch action {
        case .viewDidLoad, .refresh:
            base.fetchUsers()
        case .selectItem(let id):
            base.selectedIDSubject.send(id)
        }
    }

    func updateViewObject(_ viewObjects: [ListItemViewObject]) {
        base?.viewObject = viewObjects
    }

    func handleFetchCompletion(_ completion: Subscribers.Completion<Error>) {
        guard let base else { return }
        base.isLoading = false
        if case let .failure(error) = completion {
            base.errorMessage = error.localizedDescription
        }
    }

    func handleFetchModels(_ models: [ListItemModel]) {
        base?.itemsSubject.send(models)
    }
}
