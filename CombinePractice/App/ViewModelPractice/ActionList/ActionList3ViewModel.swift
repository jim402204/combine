import Combine
import Foundation

final class ActionList3ViewModel {
    enum Action: Equatable {
        case viewDidLoad
        case refresh
        case willEnterForeground
        case selectItem(id: Int)
        case confirmSelection
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
    @Published var isConfirmEnabled = false
    @Published var confirmMessage: String? = nil
    @Published var lastFetchSource: String? = nil

    private let dependency: Dependency
    private let itemsSubject = CurrentValueSubject<[ListItemModel], Never>([])
    private let selectedIDSubject = CurrentValueSubject<Int?, Never>(nil)

    init(dependency: Dependency) {
        self.dependency = dependency
        binding()
    }

    func binding() {
        let actionStream = $action.compactMap { $0 }.eraseToAnyPublisher()

        bindFetchActions(from: actionStream)
        bindSelectItemAction(from: actionStream)
        bindConfirmSelectionAction(from: actionStream)
        bindViewObjectOutput()
    }

    // MARK: - 從 action 拆出各 trigger，再 Merge（比 ActionList2 的 compactMap 合流更清楚）

    private func bindFetchActions(from actionStream: AnyPublisher<Action, Never>) {
        let viewDidLoadTrigger = actionStream
            .filter { $0 == .viewDidLoad }
            .map { _ in "初次載入" }

        let refreshTrigger = actionStream
            .filter { $0 == .refresh }
            .map { _ in "手動刷新" }

        let foregroundTrigger = actionStream
            .filter { $0 == .willEnterForeground }
            .map { _ in "背景回前景" }

        Publishers.Merge3(viewDidLoadTrigger, refreshTrigger, foregroundTrigger)
            .sink { [weak self] source in
                self?.lastFetchSource = source
                self?.fetchUsers()
            }
            .store(in: &cancellables)
    }

    private func bindSelectItemAction(from actionStream: AnyPublisher<Action, Never>) {
        let selectItemTrigger = actionStream
            .compactMap { action -> Int? in
                if case let .selectItem(id) = action { return id }
                return nil
            }

        selectItemTrigger
            .sink { [weak self] id in
                self?.selectedIDSubject.send(id)
                self?.confirmMessage = nil
            }
            .store(in: &cancellables)

        selectedIDSubject
            .map { $0 != nil }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.isConfirmEnabled = isEnabled
            }
            .store(in: &cancellables)
    }

    // MARK: - 其實是ok的 本來就複雜，只是input個別寫可能表達更清楚 同時也要寫更多的code或是說屬性

    private func bindConfirmSelectionAction(from actionStream: AnyPublisher<Action, Never>) {
        let confirmTrigger = actionStream
            .filter { $0 == .confirmSelection }
            .map { _ in () }

        let listContext = Publishers.CombineLatest(itemsSubject, selectedIDSubject)
            .eraseToAnyPublisher()

        confirmTrigger
            .withLatestFrom(listContext) { _, context in
                context
            }
            .compactMap { models, selectedID -> ListItemModel? in
                guard let selectedID else { return nil }
                return models.first { $0.id == selectedID }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.confirmMessage = "已確認送出：\(model.name)（\(model.email)）"
            }
            .store(in: &cancellables)
    }

    private func bindViewObjectOutput() {
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
