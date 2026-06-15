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
