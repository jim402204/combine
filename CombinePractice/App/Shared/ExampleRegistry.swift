import UIKit

enum ExampleRegistry {
    static let sections: [ExampleSection] = [
        ExampleSection(title: "入門", items: [
            .init(title: "Sink & Store", subtitle: "訂閱與取消訂閱", makeViewController: { SinkStoreDemoVC() }),
            .init(title: "Just Publisher", subtitle: "建立最簡單的 Publisher", makeViewController: { JustPublisherDemoVC() }),
            .init(title: "Subject 入門", subtitle: "Passthrough vs CurrentValue", makeViewController: { SubjectIntroDemoVC() }),
        ]),
        ExampleSection(title: "封裝實戰", items: [
            .init(title: "Button Throttle", subtitle: "publisher(for:) + onThrottle()", makeViewController: { ButtonThrottleDemoVC() }),
            .init(title: "Switch", subtitle: "isOnPublisher() + sinkOnMain()", makeViewController: { SwitchDemoVC() }),
            .init(title: "Segmented Control", subtitle: "selectedSegmentIndexPublisher()", makeViewController: { SegmentedControlDemoVC() }),
            .init(title: "Scroll Reach Bottom", subtitle: "isReachBottomPublisher()", makeViewController: { ScrollReachBottomDemoVC() }),
            .init(title: "Counter ViewModel", subtitle: "ViewModelType Input/Output", makeViewController: { CounterViewModelDemoVC() }),
        ]),
        ExampleSection(title: "原生 Combine 進階", items: [
            .init(title: "Map & Filter", subtitle: "map / filter / compactMap", makeViewController: { MapFilterDemoVC() }),
            .init(title: "Merge & CombineLatest", subtitle: "原理 + 常見情境導覽", makeViewController: { MergeCombineLatestDemoVC() }),
            .init(title: "Debounce & Throttle", subtitle: "原生防抖與節流", makeViewController: { DebounceThrottleDemoVC() }),
            .init(title: "FlatMap", subtitle: "串接非同步", makeViewController: { FlatMapDemoVC() }),
            .init(title: "Share", subtitle: "多訂閱者共用上游", makeViewController: { ShareDemoVC() }),
            .init(title: "Scan", subtitle: "scan 限制輸入字數", makeViewController: { ScanDemoVC() }),
            .init(title: "SwitchToLatest", subtitle: "原理 + 常見情境導覽", makeViewController: { SwitchToLatestDemoVC() }),
            .init(title: "Catch Error", subtitle: "catch / replaceError", makeViewController: { CatchErrorDemoVC() }),
            .init(title: "Zip", subtitle: "同步兩流", makeViewController: { ZipDemoVC() }),
            .init(title: "WithLatestFrom", subtitle: "CombineExt", makeViewController: { WithLatestFromDemoVC() }),
            .init(title: "HandleEvents", subtitle: "副作用與 debug", makeViewController: { HandleEventsDemoVC() }),
            .init(title: "Assign vs Sink", subtitle: "兩種訂閱方式", makeViewController: { AssignVsSinkDemoVC() }),
        ]),
        ExampleSection(title: "ViewModel 練習", items: [
            .init(
                title: "Action List 1",
                subtitle: "action enum + switch 就夠（獨立事件）",
                makeViewController: { ActionList1DemoVC() }
            ),
            .init(
                title: "Action List 2",
                subtitle: "action enum 拆鏈：compactMap 假合流",
                makeViewController: { ActionList2DemoVC() }
            ),
            .init(
                title: "Action List 3",
                subtitle: "action 拆 trigger 變數 + Merge3",
                makeViewController: { ActionList3DemoVC() }
            ),
            .init(
                title: "List ViewModel",
                subtitle: "多 Input publisher：Merge / withLatestFrom 語意更清楚",
                makeViewController: { ListItemDemoVC() }
            ),
        ]),
        ExampleSection(title: "Combine Week", items: [
            .init(
                title: "Action List 4",
                subtitle: "weak().present + Weak extension 綁定風格",
                makeViewController: { ActionList4DemoVC() }
            ),
        ]),
    ]
}
