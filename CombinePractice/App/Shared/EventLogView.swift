import UIKit

final class EventLogView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        isEditable = false
        font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
