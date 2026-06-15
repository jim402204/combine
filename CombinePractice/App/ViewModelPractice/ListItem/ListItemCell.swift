import Combine
import UIKit

final class ListItemCell: UITableViewCell {
    static let reuseIdentifier = "ListItemCell"

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let selectButton = UIButton(type: .system)
    let tapAreaView = UIView()

    var reuseCancellables = Set<AnyCancellable>()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        reuseCancellables.removeAll()
    }

    private func setupLayout() {
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel

        selectButton.setTitle("選取", for: .normal)

        tapAreaView.backgroundColor = .secondarySystemBackground
        tapAreaView.layer.cornerRadius = 8
        tapAreaView.isUserInteractionEnabled = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let rowStack = UIStackView(arrangedSubviews: [tapAreaView, textStack, selectButton])
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .center
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            rowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            tapAreaView.widthAnchor.constraint(equalToConstant: 44),
            tapAreaView.heightAnchor.constraint(equalToConstant: 44),
            selectButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 52),
        ])
    }

    func configure(with viewObject: ListItemViewObject) {
        titleLabel.text = viewObject.title
        subtitleLabel.text = viewObject.subtitle
        applySelectionStyle(isSelected: viewObject.isSelected)
    }

    private func applySelectionStyle(isSelected: Bool) {
        contentView.backgroundColor = isSelected
            ? UIColor.systemBlue.withAlphaComponent(0.15)
            : .clear
        selectButton.setTitle(isSelected ? "已選" : "選取", for: .normal)
        tapAreaView.backgroundColor = isSelected
            ? UIColor.systemBlue.withAlphaComponent(0.35)
            : .secondarySystemBackground
    }
}
