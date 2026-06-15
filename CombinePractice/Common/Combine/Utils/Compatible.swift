protocol Compatible {}

extension Compatible where Self: AnyObject {
    func weak() -> Weak<Self> {
        Weak(self)
    }
}
