# CombinePractice 練習專案設計規格

> 日期：2026-06-12  
> 狀態：已核准

---

## 1. 目標

建立一個自包含的 iOS Combine 練習專案，供個人練習與團隊導入參考。專案包含：

1. 從既有 Combine 封裝移植並**改為中性命名**的封裝層
2. 三區塊、共 20 個可互動小範例
3. 首頁以 `UITableView` 列表導航，點選後 `push` 進入各範例

---

## 2. 技術選型

| 項目 | 決策 |
|------|------|
| 專案名稱 | `CombinePractice` |
| UI 框架 | UIKit，程式碼建 UI（無 Storyboard） |
| 導航 | `UINavigationController` + 三區塊 `UITableView` |
| 最低版本 | iOS 13.0 |
| 依賴管理 | **Swift Package Manager（SPM）** |
| 第三方套件 | `CombineExt` ≥ 1.8.0（透過 Xcode SPM 加入） |
| 封裝整合 | 方案 A：直接複製封裝檔至 `Common/Combine/` |
| 前綴 | **移除舊前綴**，改為中性命名（見 §4） |

---

## 3. 專案結構

```
CombinePractice/
├── CombinePractice.xcodeproj
├── CombinePractice.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/
│   └── Package.resolved          # Xcode 自動產生，需納入版控
├── README.md
├── Common/Combine/
│   ├── Extensions/
│   │   ├── Publisher+Combine.swift
│   │   ├── PublisherThrottleSetting.swift
│   │   ├── UIControl+Combine.swift
│   │   ├── UISwitch+Combine.swift
│   │   ├── UISegmentedControl+Combine.swift
│   │   ├── UIView+Gesture+Combine.swift
│   │   └── UIScrollView+Combine.swift
│   ├── Protocol/
│   │   └── ViewModelType.swift
│   └── Utils/
│       ├── Compatible.swift
│       ├── Weak+Compatible.swift
│       └── UIScrollView+ReachBottom.swift
└── App/
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    ├── Home/
    │   ├── HomeListViewController.swift
    │   └── ExampleItem.swift
    ├── Shared/
    │   ├── DemoViewController.swift
    │   ├── EventLogView.swift
    │   └── ExampleRegistry.swift
    ├── Beginner/          # 3 個入門範例
    ├── EncapsulationDemo/ # 5 個封裝實戰範例
    └── Advanced/          # 12 個進階範例
```

---

## 4. 封裝 API 命名（中性命名）

移植後，本專案採用以下公開 API：

| API (CombinePractice) |
|---|
| `ViewModelType` |
| `transform(from:)` |
| `onThrottle()` |
| `sinkOnMain()` |
| `assignOnMain()` |
| `publisher(for:)` |
| `isOnPublisher()` |
| `selectedSegmentIndexPublisher()` |
| `tapPublisher()` |
| `longPressPublisher()` |
| `isReachBottomPublisher()` |
| `isScrollingPublisher()` |
| `PublisherThrottleSetting` |
| `Compatible` / `weak()` |
| `Weak` (Compatible 命名空間) |

實作時以專案內全文搜尋確認封裝層命名一致。

---

## 5. 首頁導航

### 5.1 三區塊列表（由上到下）

| Section | 標題 | 數量 |
|---------|------|------|
| 0 | 入門 | 3 |
| 1 | 封裝實戰 | 5 |
| 2 | 原生 Combine 進階 | 12 |

### 5.2 資料模型

```swift
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

`ExampleRegistry` 以靜態陣列定義所有 section；新增範例只需註冊一筆。

---

## 6. 範例清單（共 20 個）

### 6.1 入門（3 個）

| # | VC | 教學重點 |
|---|-----|---------|
| 1 | `SinkStoreDemoVC` | `sink` + `store(in:)` + `AnyCancellable` 生命週期 |
| 2 | `JustPublisherDemoVC` | `Just`、`Publishers.Sequence`、鏈式 `map` |
| 3 | `SubjectIntroDemoVC` | `PassthroughSubject` vs `CurrentValueSubject` |

### 6.2 封裝實戰（5 個）

| # | VC | 教學重點 |
|---|-----|---------|
| 4 | `ButtonThrottleDemoVC` | `publisher(for:)` + `onThrottle()` |
| 5 | `SwitchDemoVC` | `isOnPublisher()` + `sinkOnMain()` |
| 6 | `SegmentedControlDemoVC` | `selectedSegmentIndexPublisher()` |
| 7 | `ScrollReachBottomDemoVC` | `isReachBottomPublisher()` 控制底線顯示 |
| 8 | `CounterViewModelDemoVC` | `ViewModelType` Input/Output 完整流程 |

`CounterViewModelDemoVC` 搭配 `CounterViewModel`，結構如下：

```swift
final class CounterViewModel: ViewModelType {
    struct Dependency { let initialCount: Int }
    struct Input {
        let didTapPlus: AnyPublisher<Void, Never>
        let didTapMinus: AnyPublisher<Void, Never>
    }
    struct Output {
        let countText: AnyPublisher<String, Never>
    }
    func transform(from input: Input) -> Output { ... }
}
```

### 6.3 原生 Combine 進階（12 個）

| # | VC | 教學重點 |
|---|-----|---------|
| 9 | `MapFilterDemoVC` | `map` / `filter` / `compactMap` |
| 10 | `MergeCombineLatestDemoVC` | `Publishers.Merge` / `combineLatest` |
| 11 | `DebounceThrottleDemoVC` | 原生 `debounce` vs `throttle` |
| 12 | `FlatMapDemoVC` | `flatMap` 串接非同步 |
| 13 | `ShareDemoVC` | `.share()` 多訂閱者共用上游 |
| 14 | `ScanDemoVC` | `scan` 累積狀態 |
| 15 | `SwitchToLatestDemoVC` | `switchToLatest` 取消舊請求 |
| 16 | `CatchErrorDemoVC` | `catch` / `replaceError` |
| 17 | `ZipDemoVC` | `zip` 同步兩流 |
| 18 | `WithLatestFromDemoVC` | CombineExt `withLatestFrom` |
| 19 | `HandleEventsDemoVC` | `handleEvents` 副作用 |
| 20 | `AssignVsSinkDemoVC` | `assign` vs `sink` 差異 |

---

## 7. 範例頁共通版型

所有 Demo VC 繼承 `DemoViewController`：

```
┌─────────────────────────────┐
│  Navigation Title           │
├─────────────────────────────┤
│  說明 Label（這頁教什麼）      │
├─────────────────────────────┤
│  互動 UI 區（按鈕/開關/輸入）   │
├─────────────────────────────┤
│  EventLogView（UITextView）  │
│  [12:01:03] value: 42       │
│  [12:01:04] completed       │
└─────────────────────────────┘
```

### 7.1 `EventLogView`

- 提供 `append(_ text: String)` 方法
- 自動加上時間戳
- 新訊息 scroll 到底部
- 各範例在 `sink` / `handleEvents` 中寫入 log

### 7.2 `DemoViewController`

- 統一 layout：說明 label + 內容容器 + log 區
- 子類別 override `setupDemoContent()` 填入互動 UI
- 子類別在 `viewDidLoad` 綁定 Combine pipeline

---

## 8. 資料流

```
HomeListViewController
  └─ didSelectRow → navigationController.push(ExampleVC)
                        ├─ UI 事件 → Publisher
                        ├─ (封裝區) viewModel.transform(Input) → Output
                        └─ sinkOnMain / assign → UI 更新 + EventLog
```

### 8.1 Cancellable 管理

- ViewController 層：`private var cancellables = Set<AnyCancellable>()`
- ViewModel 層：`private var cancellables = Set<AnyCancellable>()`（統一複數命名）

### 8.2 錯誤處理

- 入門區、封裝區：全部 `Failure == Never`
- 進階區：僅 `CatchErrorDemoVC` 示範 `Failure` 型別與 recovery；其餘維持 `Never`

---

## 9. 封裝檔清單（本專案）

| 路徑 |
|------|
| `Common/Combine/Extensions/Publisher+Combine.swift` |
| `Common/Combine/Extensions/PublisherThrottleSetting.swift` |
| `Common/Combine/Extensions/UIControl+Combine.swift` |
| `Common/Combine/Extensions/UISwitch+Combine.swift` |
| `Common/Combine/Extensions/UISegmentedControl+Combine.swift` |
| `Common/Combine/Extensions/UIView+Gesture+Combine.swift` |
| `Common/Combine/Extensions/UIScrollView+Combine.swift` |
| `Common/Combine/Protocol/ViewModelType.swift` |
| `Common/Combine/Utils/Compatible.swift` |
| `Common/Combine/Utils/Weak+Compatible.swift` |
| `Common/Combine/Utils/UIScrollView+ReachBottom.swift` |

移植後移除來源專案專屬 import / 依賴。

---

## 10. Swift Package Manager 設定

不使用 CocoaPods / Podfile。僅 `CombineExt` 透過 SPM 引入；`Common/Combine/` 封裝檔仍為專案內原始碼。

### 10.1 套件資訊

| 項目 | 值 |
|------|-----|
| URL | `https://github.com/CombineCommunity/CombineExt.git` |
| 版本規則 | Up to Next Major Version，from `1.8.0` |
| Link target | `CombinePractice` |

### 10.2 Xcode 加入步驟

1. 開啟 `CombinePractice.xcodeproj`
2. Project → Package Dependencies → **+**
3. 貼上 URL，選擇版本規則 `1.8.0` up to next major
4. Add to target：`CombinePractice`
5. 確認 `Package.resolved` 已產生並 commit

### 10.3 使用方式

```swift
import Combine
import CombineExt  // mapToVoid、withLatestFrom、Publishers.Merge 等
```

### 10.4 與 CocoaPods 的差異

| 項目 | SPM（本專案） | CocoaPods |
|------|--------------|-----------|
| 開啟方式 | `.xcodeproj` | `.xcworkspace` |
| 依賴檔 | `Package.resolved` | `Podfile` + `Podfile.lock` |
| 封裝檔 | 仍複製至 `Common/Combine/` | 同左 |

若目標專案使用 CocoaPods，搬移封裝檔時只需調整 CombineExt 的引入方式，封裝 API 不變。

---

## 11. README 內容

1. 專案目的：個人練習 + 團隊 Combine 導入參考
2. 建議學習順序：入門 → 封裝實戰 → 進階
3. 安裝步驟：clone 後直接開啟 `CombinePractice.xcodeproj`（Xcode 會自動 resolve SPM）
4. 封裝檔搬移指南：如何複製 `Common/Combine/` 到其他專案
5. 命名對照表（§4）
6. 每個範例的簡短操作說明

---

## 12. 測試策略

- 不建立 Unit Test target
- 以手動操作 + `EventLogView` 輸出驗證行為
- README 列出各範例的預期操作結果

---

## 13. 明確排除範圍

- Socket / 網路封裝 Demo（指南可選項，本次不做）
- SwiftUI 範例
- RxSwift 過渡示範
- 手勢 Publisher 中標記「未測試」的 swipe / pan / pinch / edge（不納入本次範例）
- 前綴替換為其他團隊前綴（如 `pp`）；本次採中性命名

---

## 14. 實作順序建議

1. 建立 Xcode 專案 + SPM 加入 CombineExt + git init
2. 複製並重新命名 Combine 封裝檔
3. 建立共用元件（`DemoViewController`、`EventLogView`、`ExampleRegistry`）
4. 實作 `HomeListViewController`
5. 依序實作：入門 3 個 → 封裝 5 個 → 進階 12 個
6. 撰寫 README
7. 全文搜尋確認封裝層命名一致
