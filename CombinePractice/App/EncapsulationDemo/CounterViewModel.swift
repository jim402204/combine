import Combine

final class CounterViewModel: ViewModelType {
    private var cancellables = Set<AnyCancellable>()

    struct Dependency {
        let initialCount: Int
    }

    struct Input {
        let didTapPlus: AnyPublisher<Void, Never>
        let didTapMinus: AnyPublisher<Void, Never>
    }

    struct Output {
        let countText: AnyPublisher<String, Never>
    }

    private let countSubject: CurrentValueSubject<Int, Never>

    init(dependency: Dependency) {
        countSubject = .init(dependency.initialCount)
    }

    func transform(from input: Input) -> Output {
        input.didTapPlus
            .onThrottle()
            .sink { [weak self] in
                guard let self else { return }
                self.countSubject.send(self.countSubject.value + 1)
            }
            .store(in: &cancellables)

        input.didTapMinus
            .onThrottle()
            .sink { [weak self] in
                guard let self else { return }
                self.countSubject.send(self.countSubject.value - 1)
            }
            .store(in: &cancellables)

        let countText = countSubject
            .map { "Count: \($0)" }
            .eraseToAnyPublisher()

        return Output(countText: countText)
    }
}
