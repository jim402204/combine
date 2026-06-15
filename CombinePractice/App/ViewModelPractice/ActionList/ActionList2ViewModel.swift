import Combine
import CombineExt
import Foundation
/// 錯誤範例 Action input 極限可能要改多個input
final class ActionList2ViewModel {
    enum Action {
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
        bindFetchActions()
        bindSelectItemAction()
        bindConfirmSelectionAction()
        bindViewObjectOutput()
    }

    // MARK: - 多觸發合流：語意上等同 Merge3，但 enum 只能 compactMap 假裝合流

    private func bindFetchActions() {
        $action
            .compactMap { $0 }
            .compactMap { action -> String? in
                switch action {
                case .viewDidLoad: return "初次載入"
                case .refresh: return "手動刷新"
                case .willEnterForeground: return "背景回前景"
                default: return nil
                }
            }
            .sink { [weak self] source in
                self?.lastFetchSource = source
                self?.fetchUsers()
            }
            .store(in: &cancellables)
    }

    private func bindSelectItemAction() {
        $action
            .compactMap { $0 }
            .compactMap { action -> Int? in
                if case let .selectItem(id) = action { return id }
                return nil
            }
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

    // MARK: - 確認要帶狀態：filter + withLatestFrom，switch 已不夠用

    private func bindConfirmSelectionAction() {
        let listContext = Publishers.CombineLatest(itemsSubject, selectedIDSubject)
            .eraseToAnyPublisher()

        $action
            .compactMap { $0 }
            .filter {
                if case .confirmSelection = $0 { return true }
                return false
            }
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
