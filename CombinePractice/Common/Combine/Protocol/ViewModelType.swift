protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    associatedtype Dependency
    func transform(from input: Input) -> Output
}
