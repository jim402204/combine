import Combine
import Foundation

// MARK: - withLatestFrom（精簡版）
//
// 語意：trigger 發射時帶上 `other` 的最新值；`other` 單獨更新不會觸發下游。
// （與 `combineLatest` 不同——`combineLatest` 是任一邊更新都會 emit。）
//
// ## 定位（本質上就是這樣）
//
//   UI 事件（trigger）  +  UI 狀態（source / other）
//   ─────────────────────────────────────────────
//   ✅ 按鈕 tap          +  CurrentValueSubject 選取狀態
//   ✅ confirm 事件      +  CombineLatest 列表 context
//   ✅ Merge 手勢        +  contextSubject 商品 ID
//
//   UI 事件（trigger）  +  會 fail 的 API 鏈
//   ─────────────────────────────────────────────
//   ❌ 不能直接串（`Failure` 必須是 `Never`，編譯期就擋掉）
//
// 專案裡的 ActionList confirm、MergeMixedUISources 都是這個模式；
// error 處理留在 API 那層，通常不會也串不進這條 operator。
//
// 若 API 結果要參與，做法是間接的：先在別條鏈 `.catch` / `replaceError`，
// 把結果 `send` 進 `Subject`，再由 UI trigger 用 `withLatestFrom` 帶最新狀態。
//
// ## 完整版（需 error 鏈、backpressure 時）
//
//   URL:     https://github.com/CombineCommunity/CombineExt.git
//   版本:    ≥ 1.8.0（project.yml → packages → CombineExt）
//   原始碼:  Sources/Operators/WithLatestFrom.swift
//            （依賴 Sources/Common/Sink.swift、DemandBuffer.swift、Operators/Internal/Lock.swift）
//   使用:    `import CombineExt` 後直接呼叫 `.withLatestFrom(...)`
//
// ## 精簡版已知限制
//
//   1. `other` 尚無值時，trigger 會被靜默丟棄（與 CombineExt 語意相同）
//   2. 同一條 publisher 鏈被多個 subscriber 訂閱時，`other` 的 cancellable 可能被覆蓋
//   3. 僅支援 `Failure == Never`（見上方定位說明）
//   4. 無 thread-safe Lock、無 backpressure（DemandBuffer）；高併發或多執行緒要小心
//   5. 3/4 路內部以 `combineLatest` 合成一個 other，再轉呼叫 2-publisher 版

extension Publisher where Failure == Never {
    /// trigger 發射時，帶上 `other` 的最新值（`other` 單獨更新不會觸發）。
    func withLatestFrom<Other: Publisher>(
        _ other: Other
    ) -> AnyPublisher<Other.Output, Never> where Other.Failure == Never {
        withLatestFrom(other) { _, latest in latest }
    }

    /// trigger 發射時，用 `resultSelector` 合併 trigger 值與 `other` 的最新值。
    func withLatestFrom<Other: Publisher, Result>(
        _ other: Other,
        resultSelector: @escaping (Output, Other.Output) -> Result
    ) -> AnyPublisher<Result, Never> where Other.Failure == Never {
        let latest = CurrentValueSubject<Other.Output?, Never>(nil)
        var otherCancellable: AnyCancellable?

        return handleEvents(
            receiveSubscription: { _ in
                otherCancellable = other.sink { latest.send($0) }
            },
            receiveCancel: { otherCancellable?.cancel() }
        )
        .compactMap { output -> Result? in
            guard let value = latest.value else { return nil }
            return resultSelector(output, value)
        }
        .eraseToAnyPublisher()
    }

    /// trigger 發射時，帶上 `other`、`other1` 的最新值（兩者皆以 `combineLatest` 合成）。
    func withLatestFrom<Other: Publisher, Other1: Publisher>(
        _ other: Other,
        _ other1: Other1
    ) -> AnyPublisher<(Other.Output, Other1.Output), Never>
    where Other.Failure == Never, Other1.Failure == Never {
        withLatestFrom(other, other1) { $1 }
    }

    /// trigger 發射時，用 `resultSelector` 合併 trigger 值與 `other`、`other1` 的最新值。
    func withLatestFrom<Other: Publisher, Other1: Publisher, Result>(
        _ other: Other,
        _ other1: Other1,
        resultSelector: @escaping (Output, (Other.Output, Other1.Output)) -> Result
    ) -> AnyPublisher<Result, Never>
    where Other.Failure == Never, Other1.Failure == Never {
        let combined = other.combineLatest(other1).eraseToAnyPublisher()
        return withLatestFrom(combined, resultSelector: resultSelector)
    }

    /// trigger 發射時，帶上 `other`、`other1`、`other2` 的最新值（三者皆以 `combineLatest` 合成）。
    func withLatestFrom<Other: Publisher, Other1: Publisher, Other2: Publisher>(
        _ other: Other,
        _ other1: Other1,
        _ other2: Other2
    ) -> AnyPublisher<(Other.Output, Other1.Output, Other2.Output), Never>
    where Other.Failure == Never, Other1.Failure == Never, Other2.Failure == Never {
        withLatestFrom(other, other1, other2) { $1 }
    }

    /// trigger 發射時，用 `resultSelector` 合併 trigger 值與 `other`、`other1`、`other2` 的最新值。
    func withLatestFrom<Other: Publisher, Other1: Publisher, Other2: Publisher, Result>(
        _ other: Other,
        _ other1: Other1,
        _ other2: Other2,
        resultSelector: @escaping (Output, (Other.Output, Other1.Output, Other2.Output)) -> Result
    ) -> AnyPublisher<Result, Never>
    where Other.Failure == Never, Other1.Failure == Never, Other2.Failure == Never {
        let combined = other.combineLatest(other1, other2).eraseToAnyPublisher()
        return withLatestFrom(combined, resultSelector: resultSelector)
    }
}
