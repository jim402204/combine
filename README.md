# CombinePractice

iOS Combine 練習專案，供個人練習與團隊導入參考。封裝自既有 Combine kit 移植並改為中性命名，搭配互動小範例。

## 需求

- Xcode 15+
- iOS 13.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)（產生 xcodeproj）

## 執行方式

```bash
cd /path/to/combine
xcodegen generate
open CombinePractice.xcodeproj
```

Xcode 會自動解析專案，選擇模擬器後 Run。

## 學習順序

1. **入門** — sink/store、Just、Subject、**Combine Debug**
2. **封裝實戰** — UIKit → Publisher、ViewModelType
3. **原生 Combine 進階** — operator 與情境

## 範例操作說明

| 範例 | 操作 | 預期結果 |
|------|------|----------|
| Sink & Store | 開始/取消訂閱 | log 每秒 tick 或停止 |
| Just Publisher | 執行 | log 印出 Just 30 與 Sequence |
| Subject 入門 | 進頁面後發送 | CurrentValue 立即印初始值 |
| Combine Debug | 依序按三個按鈕 | ① print ② debug（含行號）③ handleEvents 寫入 eventLog |
| Button Throttle | 連點按鈕 | 0.5s 內只觸發一次 |
| Switch | 切換開關 | 狀態 label 與 log 更新 |
| Segmented Control | 切換 segment | log 印 index |
| Scroll Reach Bottom | 滾動列表 | 到底隱藏紅底線 |
| Counter ViewModel | +/- 按鈕 | 計數更新 |
| Map & Filter | 發送隨機數 | 僅 >10 的值出現 |
| Merge & CombineLatest | Send A/B | Merge / combineLatest log；常見情境含多按鈕、刷新觸發、多 UI 同類事件、按鈕 Enable |
| Debounce & Throttle | 連點 | 兩種節流 log |
| FlatMap | 請求 | 1 秒後印 response |
| Share | 觸發上游 | upstream 只執行一次，兩 subscriber 都收到 |
| Scan | +1 | sum 累加 |
| SwitchToLatest | 慢→快請求 | 出現「已取消舊請求: slow」，最後只印「結果: fast」；可進「常見使用情境」看搜尋/Segment/切換標的 |
| Catch Error | 失敗/成功 | 失敗印 fallback |
| Zip | Send Pair | zip 配對輸出 |
| WithLatestFrom | Update + Trigger | trigger 帶最新 source |
| HandleEvents | 執行 | 印 subscription 生命週期 |
| Assign vs Sink | 更新 | 兩 label 同步更新 |

## 專案結構

```
CombinePractice/
├── Common/Combine/     # 封裝原始碼
└── App/
    ├── Beginner/       # 入門 4 個
    ├── EncapsulationDemo/  # 封裝 5 個
    └── Advanced/       # 進階 12 個
```
