import UIKit

extension UIScrollView {
    func isReachBottom(offset: CGFloat = 0.001) -> Bool {
        reachBottomOffset(offset) > 0
    }

    func reachBottomOffset(_ offset: CGFloat = 0.001) -> CGFloat {
        let y = contentOffset.y
        return offset - (contentSize.height - (y + frame.height + contentInset.top + contentInset.bottom))
    }
}
