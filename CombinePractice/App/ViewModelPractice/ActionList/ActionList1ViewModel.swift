import Combine
import Foundation

final class ActionList1ViewModel {
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
    private let itemsSubject = CurrentValueSubject<[ListItemModel], Never>([])
    private let selectedIDSubject = CurrentValueSubject<Int?, Never>(nil)

    init(dependency: Dependency) {
        self.dependency = dependency
        binding()
    }

    func binding() {
        $action
            .compactMap { $0 }
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .viewDidLoad, .refresh:
                    self.fetchUsers()
                case .selectItem(let id):
                    self.selectedIDSubject.send(id)
                }
            }
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
            .sink { [weak self] viewObjects in
                self?.viewObject = viewObjects
            }
            .store(in: &cancellables)
    }

    private func fetchUsers() {
        isLoading = true
        errorMessage = nil

        dependency.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] models in
                    self?.itemsSubject.send(models)
                }
            )
            .store(in: &cancellables)
    }
}
