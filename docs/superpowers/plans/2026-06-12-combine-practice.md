# CombinePractice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立一個 UIKit Combine 練習 App，含三區塊 20 個互動範例、移植既有封裝並改為中性命名，以及 SPM 引入 CombineExt。

**Architecture:** 單一 `CombinePractice` target；`Common/Combine/` 放封裝原始碼；`App/` 放 UI 與範例；`HomeListViewController` 透過 `ExampleRegistry` 導航至各 `DemoViewController` 子類別。

**Tech Stack:** Swift 5、UIKit（程式碼 UI）、Combine、CombineExt（SPM）、iOS 13.0+、XcodeGen（產生 xcodeproj）

**Spec:** `docs/superpowers/specs/2026-06-12-combine-practice-design.md`

---

## File Map

| 路徑 | 職責 |
|------|------|
| `project.yml` | XcodeGen 專案定義 + SPM 依賴 |
| `CombinePractice/Info.plist` | App 設定（無 Storyboard） |
| `CombinePractice/App/AppDelegate.swift` | App 生命週期 |
| `CombinePractice/App/SceneDelegate.swift` | 設定 root VC |
| `CombinePractice/Common/Combine/**` | 封裝（移植並重新命名） |
| `CombinePractice/App/Shared/EventLogView.swift` | 底部事件 log |
| `CombinePractice/App/Shared/DemoViewController.swift` | 範例頁 base class |
| `CombinePractice/App/Shared/ExampleItem.swift` | 列表資料模型 |
| `CombinePractice/App/Shared/ExampleRegistry.swift` | 三區塊 20 筆註冊 |
| `CombinePractice/App/Home/HomeListViewController.swift` | 首頁三區塊列表 |
| `CombinePractice/App/Beginner/*.swift` | 入門 3 個 |
| `CombinePractice/App/EncapsulationDemo/*.swift` | 封裝 5 個 |
| `CombinePractice/App/Advanced/*.swift` | 進階 12 個 |
| `README.md` | 學習路徑與操作說明 |

---

### Task 1: 專案骨架與 SPM

**Files:**
- Create: `project.yml`
- Create: `CombinePractice/Info.plist`
- Create: `CombinePractice/App/AppDelegate.swift`
- Create: `CombinePractice/App/SceneDelegate.swift`

- [ ] **Step 1: 安裝 XcodeGen（若尚未安裝）**

```bash
brew install xcodegen
```

Expected: `xcodegen --version` 印出版本號

- [ ] **Step 2: 建立 `project.yml`**

```yaml
name: CombinePractice
options:
  bundleIdPrefix: com.combinepractice
  deploymentTarget:
    iOS: "13.0"
  xcodeVersion: "15.0"
packages:
  CombineExt:
    url: https://github.com/CombineCommunity/CombineExt.git
    from: 1.8.0
targets:
  CombinePractice:
    type: application
    platform: iOS
    sources:
      - path: CombinePractice
    dependencies:
      - package: CombineExt
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.combinepractice.app
        INFOPLIST_FILE: CombinePractice/Info.plist
        SWIFT_VERSION: "5.0"
        TARGETED_DEVICE_FAMILY: "1,2"
        GENERATE_INFOPLIST_FILE: NO
```

- [ ] **Step 3: 建立 `CombinePractice/Info.plist`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
        <key>UISceneConfigurations</key>
        <dict>
            <key>UIWindowSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneConfigurationName</key>
                    <string>Default Configuration</string>
                    <key>UISceneDelegateClassName</key>
                    <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                </dict>
            </array>
        </dict>
    </dict>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
</dict>
</plist>
```

- [ ] **Step 4: 建立 `AppDelegate.swift`**

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
```

- [ ] **Step 5: 建立 `SceneDelegate.swift`**

```swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let home = HomeListViewController()
        window.rootViewController = UINavigationController(rootViewController: home)
        window.makeKeyAndVisible()
        self.window = window
    }
}
```

- [ ] **Step 6: 產生 Xcode 專案並 resolve SPM**

```bash
cd /Users/jim.chiang/Desktop/combine
xcodegen generate
xcodebuild -project CombinePractice.xcodeproj -scheme CombinePractice -resolvePackageDependencies
```

Expected: `CombinePractice.xcodeproj` 與 `Package.resolved` 產生，無 error

- [ ] **Step 7: Commit**

```bash
git add project.yml CombinePractice/Info.plist CombinePractice/App/AppDelegate.swift CombinePractice/App/SceneDelegate.swift CombinePractice.xcodeproj
git commit -m "feat: scaffold CombinePractice project with SPM CombineExt"
```

---

### Task 2: Combine 封裝檔（移植 + 中性命名）

**Files:**
- Create: `CombinePractice/Common/Combine/Extensions/Publisher+Combine.swift`
- Create: `CombinePractice/Common/Combine/Extensions/PublisherThrottleSetting.swift`
- Create: `CombinePractice/Common/Combine/Extensions/UIControl+Combine.swift`
- Create: `CombinePractice/Common/Combine/Extensions/UISwitch+Combine.swift`
- Create: `CombinePractice/Common/Combine/Extensions/UISegmentedControl+Combine.swift`
- Create: `CombinePractice/Common/Combine/Extensions/UIView+Gesture+Combine.swift`
- Create: `CombinePractice/Common/Combine/Extensions/UIScrollView+Combine.swift`
- Create: `CombinePractice/Common/Combine/Protocol/ViewModelType.swift`
- Create: `CombinePractice/Common/Combine/Utils/Compatible.swift`
- Create: `CombinePractice/Common/Combine/Utils/Weak+Compatible.swift`
- Create: `CombinePractice/Common/Combine/Utils/UIScrollView+ReachBottom.swift`

**參考：** spec §9 封裝檔清單

- [ ] **Step 1: 建立 `PublisherThrottleSetting.swift`**

```swift
import Foundation

struct PublisherThrottleSetting {
    var seconds: Double = 0.5
    var isLatest: Bool = false
}
```

- [ ] **Step 2: 建立 `Publisher+Combine.swift`**

```swift
import Combine
import Foundation

extension Publisher {
    func onThrottle<S>(
        settings: PublisherThrottleSetting = .init(),
        scheduler: S = RunLoop.main
    ) -> Publishers.Throttle<Self, S> where S: Scheduler {
        throttle(for: .seconds(settings.seconds), scheduler: scheduler, latest: settings.isLatest)
    }

    func debug(_ prefix: String = "", file: String = #file, line: Int = #line, to stream: TextOutputStream? = nil) -> Publishers.Print<Self> {
        print("\(prefix): \(URL(fileURLWithPath: file).lastPathComponent)-line:\(line)", to: stream)
    }
}

extension Publisher where Failure == Never {
    func sinkOnMain(
        isRemoveDuplicates: Bool = true,
        storeIn cancellables: inout Set<AnyCancellable>,
        action: @escaping (Output) -> Void
    ) {
        let publisher: AnyPublisher<Output, Failure> = if isRemoveDuplicates, Output.self is any Equatable.Type {
            (self as? Publishers.RemoveDuplicates<Self>)?.eraseToAnyPublisher() ?? eraseToAnyPublisher()
        } else {
            eraseToAnyPublisher()
        }
        publisher.receive(on: DispatchQueue.main).sink { value in action(value) }.store(in: &cancellables)
    }

    func assignOnMain<Root>(
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on object: Root,
        isRemoveDuplicates: Bool = true,
        storeIn cancellables: inout Set<AnyCancellable>
    ) {
        let publisher: AnyPublisher<Output, Failure> = if isRemoveDuplicates, Output.self is any Equatable.Type {
            (self as? Publishers.RemoveDuplicates<Self>)?.eraseToAnyPublisher() ?? eraseToAnyPublisher()
        } else {
            eraseToAnyPublisher()
        }
        publisher.receive(on: DispatchQueue.main).assign(to: keyPath, on: object).store(in: &cancellables)
    }
}
```

- [ ] **Step 3: 建立 `UIControl+Combine.swift`**

從既有 `UIControl+Combine.swift` 移植 `UIControlPublisher` / `UIControlSubscription`，公開 API 為：

```swift
import Combine
import UIKit

// ... UIControlPublisher, UIControlSubscription 保持不變 ...

extension UIControl {
    func publisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
        UIControlPublisher(control: self, events: events).eraseToAnyPublisher()
    }
}
```

- [ ] **Step 4: 建立 `UISwitch+Combine.swift`**

從既有專案移植，公開 API：`isOnPublisher()`

- [ ] **Step 5: 建立 `UISegmentedControl+Combine.swift`**

從既有專案移植，公開 API：`selectedSegmentIndexPublisher()`

- [ ] **Step 6: 建立 `UIView+Gesture+Combine.swift`**

從既有專案移植，公開 API：
- `tapPublisher()`
- `longPressPublisher()`

- [ ] **Step 7: 建立 `UIScrollView+Combine.swift` 與 `UIScrollView+ReachBottom.swift`**

先建立 `UIScrollView+ReachBottom.swift`（移植 `isReachBottom()` 邏輯）。

再建立 `UIScrollView+Combine.swift`，公開 API：
- `isReachBottomPublisher()`
- `isScrollingPublisher()`

- [ ] **Step 8: 建立 `ViewModelType.swift`**

```swift
protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    associatedtype Dependency
    func transform(from input: Input) -> Output
}
```

- [ ] **Step 9: 建立 `Compatible.swift` 與 `Weak+Compatible.swift`**

```swift
// Compatible.swift
protocol Compatible {}
extension Compatible where Self: AnyObject {
    func weak() -> Weak<Self> { Weak(self) }
}

// Weak+Compatible.swift
class Weak<Base: AnyObject> {
    weak var base: Base?
    init(_ base: Base) { self.base = base }
}
```

- [ ] **Step 10: 驗證封裝層命名**

```bash
cd /Users/jim.chiang/Desktop/combine
rg 'publisher\\(for:|sinkOnMain|ViewModelType' CombinePractice/Common/Combine/
```

Expected: 命中預期 API

- [ ] **Step 11: Commit**

```bash
git add CombinePractice/Common/
git commit -m "feat: add Combine kit with neutral naming"
```

---

### Task 3: 共用 UI 元件

**Files:**
- Create: `CombinePractice/App/Shared/EventLogView.swift`
- Create: `CombinePractice/App/Shared/DemoViewController.swift`
- Create: `CombinePractice/App/Shared/ExampleItem.swift`

- [ ] **Step 1: 建立 `ExampleItem.swift`**

```swift
import UIKit

struct ExampleItem {
    let title: String
    let subtitle: String
    let viewControllerType: UIViewController.Type
}

struct ExampleSection {
    let title: String
    let items: [ExampleItem]
}
```

- [ ] **Step 2: 建立 `EventLogView.swift`**

```swift
import UIKit

final class EventLogView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        isEditable = false
        font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func append(_ text: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        let line = "[\(timestamp)] \(text)\n"
        self.text += line
        let bottom = NSRange(location: (self.text as NSString).length - 1, length: 1)
        scrollRangeToVisible(bottom)
    }

    func clear() {
        text = ""
    }
}
```

- [ ] **Step 3: 建立 `DemoViewController.swift`**

```swift
import UIKit

class DemoViewController: UIViewController {
    let descriptionText: String
    let eventLog = EventLogView()

    private let descriptionLabel = UILabel()
    private let contentContainer = UIView()

    init(title: String, description: String) {
        self.descriptionText = description
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupDemoContent()
    }

    func setupDemoContent() {}

    func setupLayout() {
        descriptionLabel.text = descriptionText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [descriptionLabel, contentContainer, eventLog])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            eventLog.heightAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])
    }
}
```

- [ ] **Step 4: Commit**

```bash
git add CombinePractice/App/Shared/
git commit -m "feat: add shared demo UI components"
```

---

### Task 4: 首頁列表與範例註冊

**Files:**
- Create: `CombinePractice/App/Shared/ExampleRegistry.swift`
- Create: `CombinePractice/App/Home/HomeListViewController.swift`

- [ ] **Step 1: 建立 `ExampleRegistry.swift`**

```swift
import UIKit

enum ExampleRegistry {
    static let sections: [ExampleSection] = [
        ExampleSection(title: "入門", items: [
            .init(title: "Sink & Store", subtitle: "訂閱與取消訂閱", viewControllerType: SinkStoreDemoVC.self),
            .init(title: "Just Publisher", subtitle: "建立最簡單的 Publisher", viewControllerType: JustPublisherDemoVC.self),
            .init(title: "Subject 入門", subtitle: "Passthrough vs CurrentValue", viewControllerType: SubjectIntroDemoVC.self),
        ]),
        ExampleSection(title: "封裝實戰", items: [
            .init(title: "Button Throttle", subtitle: "publisher(for:) + onThrottle()", viewControllerType: ButtonThrottleDemoVC.self),
            .init(title: "Switch", subtitle: "isOnPublisher() + sinkOnMain()", viewControllerType: SwitchDemoVC.self),
            .init(title: "Segmented Control", subtitle: "selectedSegmentIndexPublisher()", viewControllerType: SegmentedControlDemoVC.self),
            .init(title: "Scroll Reach Bottom", subtitle: "isReachBottomPublisher()", viewControllerType: ScrollReachBottomDemoVC.self),
            .init(title: "Counter ViewModel", subtitle: "ViewModelType Input/Output", viewControllerType: CounterViewModelDemoVC.self),
        ]),
        ExampleSection(title: "原生 Combine 進階", items: [
            .init(title: "Map & Filter", subtitle: "map / filter / compactMap", viewControllerType: MapFilterDemoVC.self),
            .init(title: "Merge & CombineLatest", subtitle: "合併與同步", viewControllerType: MergeCombineLatestDemoVC.self),
            .init(title: "Debounce & Throttle", subtitle: "原生防抖與節流", viewControllerType: DebounceThrottleDemoVC.self),
            .init(title: "FlatMap", subtitle: "串接非同步", viewControllerType: FlatMapDemoVC.self),
            .init(title: "Share", subtitle: "多訂閱者共用上游", viewControllerType: ShareDemoVC.self),
            .init(title: "Scan", subtitle: "累積狀態", viewControllerType: ScanDemoVC.self),
            .init(title: "SwitchToLatest", subtitle: "取消舊請求", viewControllerType: SwitchToLatestDemoVC.self),
            .init(title: "Catch Error", subtitle: "catch / replaceError", viewControllerType: CatchErrorDemoVC.self),
            .init(title: "Zip", subtitle: "同步兩流", viewControllerType: ZipDemoVC.self),
            .init(title: "WithLatestFrom", subtitle: "CombineExt", viewControllerType: WithLatestFromDemoVC.self),
            .init(title: "HandleEvents", subtitle: "副作用與 debug", viewControllerType: HandleEventsDemoVC.self),
            .init(title: "Assign vs Sink", subtitle: "兩種訂閱方式", viewControllerType: AssignVsSinkDemoVC.self),
        ]),
    ]
}
```

- [ ] **Step 2: 建立 `HomeListViewController.swift`**

```swift
import UIKit

final class HomeListViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Combine 練習"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension HomeListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        ExampleRegistry.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ExampleRegistry.sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ExampleRegistry.sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = ExampleRegistry.sections[indexPath.section].items[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        config.secondaryText = item.subtitle
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = ExampleRegistry.sections[indexPath.section].items[indexPath.row]
        let vc = item.viewControllerType.init()
        navigationController?.pushViewController(vc, animated: true)
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add CombinePractice/App/Shared/ExampleRegistry.swift CombinePractice/App/Home/
git commit -m "feat: add home list and example registry"
```

---

### Task 5: 入門範例（3 個）

**Files:**
- Create: `CombinePractice/App/Beginner/SinkStoreDemoVC.swift`
- Create: `CombinePractice/App/Beginner/JustPublisherDemoVC.swift`
- Create: `CombinePractice/App/Beginner/SubjectIntroDemoVC.swift`

- [ ] **Step 1: 建立 `SinkStoreDemoVC.swift`**

```swift
import Combine
import UIKit

final class SinkStoreDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let subscribeButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private var tickCancellable: AnyCancellable?
    private let timerSubject = PassthroughSubject<Int, Never>()
    private var tick = 0

    init() {
        super.init(title: "Sink & Store", description: "點「開始訂閱」啟動計時，點「取消訂閱」停止。觀察 AnyCancellable 的生命週期。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        subscribeButton.setTitle("開始訂閱", for: .normal)
        cancelButton.setTitle("取消訂閱", for: .normal)
        let stack = UIStackView(arrangedSubviews: [subscribeButton, cancelButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        subscribeButton.addTarget(self, action: #selector(startSubscribe), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelSubscribe), for: .touchUpInside)
    }

    @objc private func startSubscribe() {
        tickCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.tick += 1
                self.eventLog.append("tick: \(self.tick)")
            }
        eventLog.append("已訂閱")
    }

    @objc private func cancelSubscribe() {
        tickCancellable?.cancel()
        tickCancellable = nil
        eventLog.append("已取消訂閱")
    }
}
```

- [ ] **Step 2: 建立 `JustPublisherDemoVC.swift`**

```swift
import Combine
import UIKit

final class JustPublisherDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let runButton = UIButton(type: .system)

    init() {
        super.init(title: "Just Publisher", description: "Just 與 Sequence 發出固定值，再經 map 轉換。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        runButton.setTitle("執行", for: .normal)
        runButton.addTarget(self, action: #selector(run), for: .touchUpInside)
        runButton.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(runButton)
        NSLayoutConstraint.activate([
            runButton.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            runButton.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            runButton.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
    }

    @objc private func run() {
        eventLog.clear()
        Just(3)
            .map { $0 * 10 }
            .sink { [weak self] value in self?.eventLog.append("Just result: \(value)") }
            .store(in: &cancellables)

        Publishers.Sequence(sequence: [1, 2, 3])
            .map { "item-\($0)" }
            .sink { [weak self] value in self?.eventLog.append("Sequence: \(value)") }
            .store(in: &cancellables)
    }
}
```

- [ ] **Step 3: 建立 `SubjectIntroDemoVC.swift`**

```swift
import Combine
import UIKit

final class SubjectIntroDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let passthroughButton = UIButton(type: .system)
    private let currentValueButton = UIButton(type: .system)
    private let passthroughSubject = PassthroughSubject<String, Never>()
    private let currentValueSubject = CurrentValueSubject<String, Never>("初始值")

    init() {
        super.init(title: "Subject 入門", description: "Passthrough 不保留值；CurrentValue 訂閱時立即拿到最新值。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        passthroughSubject.sink { [weak self] v in self?.eventLog.append("Passthrough: \(v)") }.store(in: &cancellables)
        currentValueSubject.sink { [weak self] v in self?.eventLog.append("CurrentValue: \(v)") }.store(in: &cancellables)
    }

    override func setupDemoContent() {
        passthroughButton.setTitle("Send Passthrough", for: .normal)
        currentValueButton.setTitle("Send CurrentValue", for: .normal)
        passthroughButton.addTarget(self, action: #selector(sendPassthrough), for: .touchUpInside)
        currentValueButton.addTarget(self, action: #selector(sendCurrentValue), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [passthroughButton, currentValueButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
    }

    @objc private func sendPassthrough() { passthroughSubject.send("事件 \(Int.random(in: 1...99))") }
    @objc private func sendCurrentValue() { currentValueSubject.send("更新 \(Int.random(in: 1...99))") }
}
```

- [ ] **Step 4: 手動驗證**

Run: `xcodebuild -project CombinePractice.xcodeproj -scheme CombinePractice -destination 'platform=iOS Simulator,name=iPhone 16' build`

Expected: BUILD SUCCEEDED

- [ ] **Step 5: Commit**

```bash
git add CombinePractice/App/Beginner/
git commit -m "feat: add beginner Combine demos"
```

---

### Task 6: 封裝實戰範例（5 個）

**Files:**
- Create: `CombinePractice/App/EncapsulationDemo/ButtonThrottleDemoVC.swift`
- Create: `CombinePractice/App/EncapsulationDemo/SwitchDemoVC.swift`
- Create: `CombinePractice/App/EncapsulationDemo/SegmentedControlDemoVC.swift`
- Create: `CombinePractice/App/EncapsulationDemo/ScrollReachBottomDemoVC.swift`
- Create: `CombinePractice/App/EncapsulationDemo/CounterViewModel.swift`
- Create: `CombinePractice/App/EncapsulationDemo/CounterViewModelDemoVC.swift`

- [ ] **Step 1: 建立 `ButtonThrottleDemoVC.swift`**

```swift
import Combine
import UIKit

final class ButtonThrottleDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)

    init() {
        super.init(title: "Button Throttle", description: "快速連點按鈕，onThrottle(0.5s) 限制觸發頻率。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("連點我", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        button.publisher(for: .touchUpInside)
            .onThrottle()
            .sink { [weak self] in self?.eventLog.append("throttled tap") }
            .store(in: &cancellables)
    }
}
```

- [ ] **Step 2: 建立 `SwitchDemoVC.swift`**

```swift
import Combine
import UIKit

final class SwitchDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let toggle = UISwitch()
    private let statusLabel = UILabel()

    init() {
        super.init(title: "Switch", description: "isOnPublisher() 將 UISwitch 事件轉為 Publisher。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        statusLabel.text = "狀態：關"
        let stack = UIStackView(arrangedSubviews: [toggle, statusLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        toggle.isOnPublisher()
            .sinkOnMain(storeIn: &cancellables) { [weak self] isOn in
                self?.statusLabel.text = "狀態：\(isOn ? "開" : "關")"
                self?.eventLog.append("isOn: \(isOn)")
            }
    }
}
```

- [ ] **Step 3: 建立 `SegmentedControlDemoVC.swift`**

```swift
import Combine
import UIKit

final class SegmentedControlDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let segmented = UISegmentedControl(items: ["A", "B", "C"])

    init() {
        super.init(title: "Segmented Control", description: "selectedSegmentIndexPublisher() 已 removeDuplicates。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        segmented.selectedSegmentIndex = 0
        segmented.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(segmented)
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            segmented.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            segmented.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        segmented.selectedSegmentIndexPublisher()
            .sink { [weak self] index in self?.eventLog.append("selected index: \(index)") }
            .store(in: &cancellables)
    }
}
```

- [ ] **Step 4: 建立 `ScrollReachBottomDemoVC.swift`**

```swift
import Combine
import UIKit

final class ScrollReachBottomDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let scrollView = UIScrollView()
    private let bottomLine = UIView()

    init() {
        super.init(title: "Scroll Reach Bottom", description: "滾到底時隱藏底線，未到底時顯示。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .systemRed
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(scrollView)
        contentContainer.addSubview(bottomLine)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)
        let box = UIView()
        box.backgroundColor = .systemBlue
        box.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(box)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 200),
            content.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            box.topAnchor.constraint(equalTo: content.topAnchor),
            box.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            box.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            box.heightAnchor.constraint(equalToConstant: 400),
            box.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            bottomLine.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            bottomLine.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 2),
            bottomLine.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        scrollView.isReachBottomPublisher()
            .sink { [weak self] isReachBottom in
                self?.bottomLine.isHidden = isReachBottom
                self?.eventLog.append("isReachBottom: \(isReachBottom)")
            }
            .store(in: &cancellables)
    }
}
```

- [ ] **Step 5: 建立 `CounterViewModel.swift` 與 `CounterViewModelDemoVC.swift`**

```swift
// CounterViewModel.swift
import Combine
import CombineExt

final class CounterViewModel: ViewModelType {
    private var cancellables = Set<AnyCancellable>()
    struct Dependency { let initialCount: Int }
    struct Input {
        let didTapPlus: AnyPublisher<Void, Never>
        let didTapMinus: AnyPublisher<Void, Never>
    }
    struct Output { let countText: AnyPublisher<String, Never> }
    private let countSubject: CurrentValueSubject<Int, Never>
    init(dependency: Dependency) { countSubject = .init(dependency.initialCount) }

    func transform(from input: Input) -> Output {
        input.didTapPlus.onThrottle().sink { [weak self] in
            guard let self else { return }
            self.countSubject.send(self.countSubject.value + 1)
        }.store(in: &cancellables)
        input.didTapMinus.onThrottle().sink { [weak self] in
            guard let self else { return }
            self.countSubject.send(self.countSubject.value - 1)
        }.store(in: &cancellables)
        let countText = countSubject.map { "Count: \($0)" }.eraseToAnyPublisher()
        return Output(countText: countText)
    }
}

// CounterViewModelDemoVC.swift
import Combine
import UIKit

final class CounterViewModelDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let plusButton = UIButton(type: .system)
    private let minusButton = UIButton(type: .system)
    private let countLabel = UILabel()
    private let viewModel = CounterViewModel(dependency: .init(initialCount: 0))

    init() {
        super.init(title: "Counter ViewModel", description: "ViewModelType Input/Output 完整綁定流程。")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        plusButton.setTitle("+", for: .normal)
        minusButton.setTitle("-", for: .normal)
        countLabel.font = .systemFont(ofSize: 24, weight: .bold)
        let stack = UIStackView(arrangedSubviews: [minusButton, countLabel, plusButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        let input = CounterViewModel.Input(
            didTapPlus: plusButton.publisher(for: .touchUpInside),
            didTapMinus: minusButton.publisher(for: .touchUpInside)
        )
        let output = viewModel.transform(from: input)
        output.countText.sinkOnMain(storeIn: &cancellables) { [weak self] text in
            self?.countLabel.text = text
            self?.eventLog.append(text)
        }
    }
}
```

- [ ] **Step 6: Commit**

```bash
git add CombinePractice/App/EncapsulationDemo/
git commit -m "feat: add encapsulation demo view controllers"
```

---

### Task 7: 進階範例（12 個）

**Files:**（各一個 `.swift` 於 `CombinePractice/App/Advanced/`）

- [ ] **Step 1: 建立 `MapFilterDemoVC.swift`**

```swift
import Combine
import UIKit

final class MapFilterDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)
    private let subject = PassthroughSubject<Int, Never>()

    init() {
        super.init(title: "Map & Filter", description: "map 轉換、filter 過濾、compactMap 去除 nil。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("發送隨機數", for: .normal)
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        subject
            .map { $0 * 2 }
            .filter { $0 > 10 }
            .sink { [weak self] v in self?.eventLog.append("passed: \(v)") }
            .store(in: &cancellables)
    }
    @objc private func send() { subject.send(Int.random(in: 1...10)) }
}
```

- [ ] **Step 2: 建立 `MergeCombineLatestDemoVC.swift`**

```swift
import Combine
import UIKit

final class MergeCombineLatestDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let buttonA = UIButton(type: .system)
    private let buttonB = UIButton(type: .system)
    private let subjectA = PassthroughSubject<String, Never>()
    private let subjectB = PassthroughSubject<String, Never>()

    init() {
        super.init(title: "Merge & CombineLatest", description: "Merge 合併事件；combineLatest 同步最新值。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        buttonA.setTitle("Send A", for: .normal)
        buttonB.setTitle("Send B", for: .normal)
        buttonA.addTarget(self, action: #selector(sendA), for: .touchUpInside)
        buttonB.addTarget(self, action: #selector(sendB), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [buttonA, buttonB])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        Publishers.Merge(subjectA, subjectB)
            .sink { [weak self] v in self?.eventLog.append("Merge: \(v)") }
            .store(in: &cancellables)
        subjectA.combineLatest(subjectB)
            .sink { [weak self] a, b in self?.eventLog.append("combineLatest: \(a) + \(b)") }
            .store(in: &cancellables)
    }
    @objc private func sendA() { subjectA.send("A\(Int.random(in: 1...9))") }
    @objc private func sendB() { subjectB.send("B\(Int.random(in: 1...9))") }
}
```

- [ ] **Step 3: 建立 `DebounceThrottleDemoVC.swift`**

```swift
import Combine
import UIKit

final class DebounceThrottleDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)
    private let subject = PassthroughSubject<Void, Never>()

    init() {
        super.init(title: "Debounce & Throttle", description: "debounce 等靜止；throttle 固定間隔。連點比較差異。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("連點", for: .normal)
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        subject.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] in self?.eventLog.append("debounce fired") }
            .store(in: &cancellables)
        subject.throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: false)
            .sink { [weak self] in self?.eventLog.append("throttle fired") }
            .store(in: &cancellables)
    }
    @objc private func tap() { subject.send() }
}
```

- [ ] **Step 4: 建立 `FlatMapDemoVC.swift`**

```swift
import Combine
import UIKit

final class FlatMapDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)

    init() {
        super.init(title: "FlatMap", description: "每次點擊 flatMap 至延遲 Publisher，模擬非同步請求。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("請求", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        button.publisher(for: .touchUpInside)
            .flatMap { id -> AnyPublisher<String, Never> in
                let requestId = Int.random(in: 100...999)
                return Just("response-\(requestId)")
                    .delay(for: .seconds(1), scheduler: RunLoop.main)
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] value in self?.eventLog.append(value) }
            .store(in: &cancellables)
    }
}
```

- [ ] **Step 5: 建立 `ShareDemoVC.swift`**

```swift
import Combine
import UIKit

final class ShareDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)

    init() {
        super.init(title: "Share", description: "share() 讓多個 sink 共用同一上游，避免重複執行。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("觸發上游", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        let shared = button.publisher(for: .touchUpInside)
            .handleEvents(receiveOutput: { _ in print("upstream executed") })
            .share()
        shared.sink { [weak self] in self?.eventLog.append("subscriber 1") }.store(in: &cancellables)
        shared.sink { [weak self] in self?.eventLog.append("subscriber 2") }.store(in: &cancellables)
    }
}
```

- [ ] **Step 6: 建立 `ScanDemoVC.swift`**

```swift
import Combine
import UIKit

final class ScanDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)
    private let subject = PassthroughSubject<Int, Never>()

    init() {
        super.init(title: "Scan", description: "scan 累加每次發出的值。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("+1", for: .normal)
        button.addTarget(self, action: #selector(add), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        subject.scan(0, +).sink { [weak self] sum in self?.eventLog.append("sum: \(sum)") }.store(in: &cancellables)
    }
    @objc private func add() { subject.send(1) }
}
```

- [ ] **Step 7: 建立 `SwitchToLatestDemoVC.swift`**

```swift
import Combine
import UIKit

final class SwitchToLatestDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let fastButton = UIButton(type: .system)
    private let slowButton = UIButton(type: .system)
    private let triggerSubject = PassthroughSubject<AnyPublisher<String, Never>, Never>()

    init() {
        super.init(title: "SwitchToLatest", description: "快速切換請求時，舊的延遲結果不會覆蓋新的。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        fastButton.setTitle("快請求", for: .normal)
        slowButton.setTitle("慢請求", for: .normal)
        fastButton.addTarget(self, action: #selector(requestFast), for: .touchUpInside)
        slowButton.addTarget(self, action: #selector(requestSlow), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [fastButton, slowButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        triggerSubject.switchToLatest()
            .sink { [weak self] value in self?.eventLog.append(value) }
            .store(in: &cancellables)
    }

    @objc private func requestFast() {
        triggerSubject.send(Just("fast").delay(for: .seconds(1), scheduler: RunLoop.main).eraseToAnyPublisher())
        eventLog.append("trigger fast")
    }

    @objc private func requestSlow() {
        triggerSubject.send(Just("slow").delay(for: .seconds(3), scheduler: RunLoop.main).eraseToAnyPublisher())
        eventLog.append("trigger slow")
    }
}
```

- [ ] **Step 8: 建立 `CatchErrorDemoVC.swift`**

```swift
import Combine
import UIKit

enum DemoError: Error { case failed }

final class CatchErrorDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let failButton = UIButton(type: .system)
    private let successButton = UIButton(type: .system)

    init() {
        super.init(title: "Catch Error", description: "失敗時 catch 改發 fallback 值。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        failButton.setTitle("觸發失敗", for: .normal)
        successButton.setTitle("觸發成功", for: .normal)
        failButton.addTarget(self, action: #selector(triggerFail), for: .touchUpInside)
        successButton.addTarget(self, action: #selector(triggerSuccess), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [failButton, successButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
    }

    @objc private func triggerFail() {
        Fail<String, DemoError>(error: .failed)
            .catch { _ in Just("fallback") }
            .sink { [weak self] value in self?.eventLog.append("result: \(value)") }
            .store(in: &cancellables)
    }

    @objc private func triggerSuccess() {
        Just("ok")
            .setFailureType(to: DemoError.self)
            .catch { _ in Just("fallback") }
            .sink { [weak self] value in self?.eventLog.append("result: \(value)") }
            .store(in: &cancellables)
    }
}
```

- [ ] **Step 9: 建立 `ZipDemoVC.swift`**

```swift
import Combine
import UIKit

final class ZipDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)
    private let subjectA = PassthroughSubject<Int, Never>()
    private let subjectB = PassthroughSubject<String, Never>()

    init() {
        super.init(title: "Zip", description: "兩流都發出時才配對輸出。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("Send Pair", for: .normal)
        button.addTarget(self, action: #selector(sendPair), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        subjectA.zip(subjectB).sink { [weak self] a, b in self?.eventLog.append("zip: \(a) + \(b)") }.store(in: &cancellables)
    }

    @objc private func sendPair() {
        let n = Int.random(in: 1...9)
        subjectA.send(n)
        subjectB.send("S\(n)")
    }
}
```

- [ ] **Step 10: 建立 `WithLatestFromDemoVC.swift`**

```swift
import Combine
import CombineExt
import UIKit

final class WithLatestFromDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let triggerButton = UIButton(type: .system)
    private let updateButton = UIButton(type: .system)
    private let trigger = PassthroughSubject<Void, Never>()
    private let source = CurrentValueSubject<String, Never>("初始")

    init() {
        super.init(title: "WithLatestFrom", description: "trigger 發生時，帶上 source 最新值（CombineExt）。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        triggerButton.setTitle("Trigger", for: .normal)
        updateButton.setTitle("Update Source", for: .normal)
        triggerButton.addTarget(self, action: #selector(fire), for: .touchUpInside)
        updateButton.addTarget(self, action: #selector(update), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [triggerButton, updateButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        trigger.withLatestFrom(source)
            .sink { [weak self] value in self?.eventLog.append("withLatestFrom: \(value)") }
            .store(in: &cancellables)
    }

    @objc private func fire() { trigger.send() }
    @objc private func update() { source.send("v\(Int.random(in: 1...99))") }
}
```

- [ ] **Step 11: 建立 `HandleEventsDemoVC.swift`**

```swift
import Combine
import UIKit

final class HandleEventsDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)

    init() {
        super.init(title: "HandleEvents", description: "在 receiveOutput 做副作用（log / analytics）。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("執行", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        button.publisher(for: .touchUpInside)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.eventLog.append("subscribed") },
                receiveOutput: { [weak self] _ in self?.eventLog.append("receiveOutput") },
                receiveCompletion: { [weak self] _ in self?.eventLog.append("completed") },
                receiveCancel: { [weak self] in self?.eventLog.append("cancelled") }
            )
            .sink { _ in }
            .store(in: &cancellables)
    }
}
```

- [ ] **Step 12: 建立 `AssignVsSinkDemoVC.swift`**

```swift
import Combine
import UIKit

final class AssignVsSinkDemoVC: DemoViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)
    private let sinkLabel = UILabel()
    private let assignLabel = UILabel()
    private let subject = CurrentValueSubject<String, Never>("")

    init() {
        super.init(title: "Assign vs Sink", description: "assign 直接綁 KeyPath；sink 可寫任意邏輯。")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupDemoContent() {
        button.setTitle("更新", for: .normal)
        sinkLabel.text = "sink: -"
        assignLabel.text = "assign: -"
        button.addTarget(self, action: #selector(update), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [button, sinkLabel, assignLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])
        subject.sink { [weak self] value in
            self?.sinkLabel.text = "sink: \(value)"
            self?.eventLog.append("sink: \(value)")
        }.store(in: &cancellables)
        subject.assign(to: \.text, on: assignLabel).store(in: &cancellables)
    }

    @objc private func update() {
        subject.send("value-\(Int.random(in: 1...99))")
    }
}
```

- [ ] **Step 13: 重新產生 xcodeproj 並 build**

```bash
cd /Users/jim.chiang/Desktop/combine
xcodegen generate
xcodebuild -project CombinePractice.xcodeproj -scheme CombinePractice -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: BUILD SUCCEEDED

- [ ] **Step 14: Commit**

```bash
git add CombinePractice/App/Advanced/
git commit -m "feat: add advanced Combine demos"
```

---

### Task 8: README 與最終驗證

**Files:**
- Create: `README.md`

- [ ] **Step 1: 建立 `README.md`**

內容須包含：
1. 專案目的（個人練習 + 團隊 Combine 導入）
2. 需求：Xcode 15+、iOS 13+
3. 執行方式：clone → 開啟 `CombinePractice.xcodeproj` → Run
4. 學習順序：入門 → 封裝實戰 → 進階
5. `Common/Combine/` 搬移指南
6. 封裝 API 一覽
7. 20 個範例各一句操作說明與預期結果

- [ ] **Step 2: 全文搜尋封裝 API**

```bash
rg 'ViewModelType|sinkOnMain|Compatible' CombinePractice/ --glob '!*.md'
```

Expected: 命中預期 API

- [ ] **Step 3: 最終 build**

```bash
xcodebuild -project CombinePractice.xcodeproj -scheme CombinePractice -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add README with learning path and migration guide"
```

---

## Spec Coverage Checklist

| Spec 需求 | 對應 Task |
|-----------|----------|
| 中性命名封裝 | Task 2 Step 10, Task 8 Step 2 |
| SPM CombineExt | Task 1 |
| 三區塊 20 範例 | Task 4–7 |
| DemoViewController + EventLog | Task 3 |
| ViewModelType Counter | Task 6 |
| 無 Socket / SwiftUI | 未建立相關檔案 |
| README | Task 8 |
| 手動驗證（無 Unit Test） | 各 Task build 步驟 |
