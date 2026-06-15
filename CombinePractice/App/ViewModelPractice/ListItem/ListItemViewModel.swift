import Combine
import Foundation

final class ListItemViewModel: ViewModelType {
    private var cancellables = Set<AnyCancellable>()

    struct Dependency {
        let fetchUsers: () -> AnyPublisher<[ListItemModel], Error>
    }

    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let didSelectItem: AnyPublisher<Int, Never>
    }

    struct Output {
        let items: AnyPublisher<[ListItemViewObject], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let errorMessage: AnyPublisher<String?, Never>
    }

    private let dependency: Dependency
    private let itemsSubject = CurrentValueSubject<[ListItemModel], Never>([])
    private let selectedIDSubject = CurrentValueSubject<Int?, Never>(nil)
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingSubject.send(true)
                self?.errorSubject.send(nil)
            })
            .flatMap { [weak self, dependency] _ -> AnyPublisher<[ListItemModel], Never> in
                dependency.fetchUsers()
                    .catch { error -> AnyPublisher<[ListItemModel], Never> in
                        self?.errorSubject.send(error.localizedDescription)
                        return Just([]).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] models in
                self?.isLoadingSubject.send(false)
                self?.itemsSubject.send(models)
            }
            .store(in: &cancellables)

        input.didSelectItem
            .sink { [weak self] id in
                self?.selectedIDSubject.send(id)
            }
            .store(in: &cancellables)

        let items = Publishers.CombineLatest(itemsSubject, selectedIDSubject)
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
            .eraseToAnyPublisher()

        return Output(
            items: items,
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            errorMessage: errorSubject.eraseToAnyPublisher()
        )
    }
}
