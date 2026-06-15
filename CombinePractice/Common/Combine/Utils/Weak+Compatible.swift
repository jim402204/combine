final class Weak<Base: AnyObject> {
    weak var base: Base?

    init(_ base: Base) {
        self.base = base
    }
}
