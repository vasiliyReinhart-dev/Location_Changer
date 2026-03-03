import UIKit
import SnapKit

final class PresetsSelectCell: UICollectionViewCell {
    
    static let id = "presetsSelectCell"
    
    private var conteinerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = UIColor(named: "767680")
        return view
    }()
    private let icon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private let nameTitle: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.numberOfLines = 0
        return view
    }()
    private let presetTitle: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(named: "9DA0AE")
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.numberOfLines = 0
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupeSubview()
        subviewConstraint()

    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let size = contentView.systemLayoutSizeFitting(targetSize,
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .fittingSizeLevel)
        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.image = nil
    }
    private func setupeSubview() {
        contentView.addSubview(conteinerView)
        conteinerView.addSubview(icon)
        conteinerView.addSubview(nameTitle)
        conteinerView.addSubview(presetTitle)
    }
    private func subviewConstraint() {
        conteinerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        icon.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.width.equalTo(88)
            make.height.equalTo(38)
        }
        nameTitle.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.greaterThanOrEqualTo(10)
        }
        presetTitle.snp.makeConstraints { make in
            make.top.equalTo(nameTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.lessThanOrEqualToSuperview().inset(10)
        }
    }
    func configure(_ data: Presets, _ select: Bool) {
        nameTitle.text = data.name
        presetTitle.text = data.title
        icon.image = select ? data.iconSelect : data.icon
        nameTitle.textColor = select ? .white : .black
        presetTitle.textColor = select ? .white : .black
        conteinerView.backgroundColor = select ? UIColor(named: "base_violet_color") : UIColor(named: "767680")
    }
}
