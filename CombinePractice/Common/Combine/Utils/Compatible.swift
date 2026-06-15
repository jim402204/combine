/// 團隊 Compatible 封裝（練習專案命名空間前綴為 `cp`）。
///
/// - `cp` / `CP<Base>`：命名空間。把 instance 包進 `CP(self)`，擴充方法寫在
///   `extension CP where Base == SomeType`，避免直接改原型別、也避免方法名稱衝突。
///   例：`value.cp.doSomething()` → `CP(value).doSomething()`。
/// - `static var cp`：型別層級命名空間，供 `SomeType.cp.xxx()` 使用（較少見）。
/// - `weak()`：Combine 綁定用，搭配同檔案的 `extension Weak where Base == Self`。
protocol Compatible {
    associatedtype CompatibleType

    static var cp: CompatibleType.Type { get }
    var cp: CompatibleType { get }
}

extension Compatible {
    static var cp: CP<Self>.Type { CP<Self>.self }
    var cp: CP<Self> { CP(self) }

    func weak() -> Weak<Self> where Self: AnyObject {
        Weak(self)
    }
}

/// 命名空間包裝盒；`base` 為被包裝的原始 instance。
struct CP<Base> {
    let base: Base

    init(_ base: Base) {
        self.base = base
    }
}
