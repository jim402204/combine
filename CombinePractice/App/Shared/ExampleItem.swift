import UIKit

struct ExampleItem {
    let title: String
    let subtitle: String
    let makeViewController: () -> UIViewController
}

struct ExampleSection {
    let title: String
    let items: [ExampleItem]
}
