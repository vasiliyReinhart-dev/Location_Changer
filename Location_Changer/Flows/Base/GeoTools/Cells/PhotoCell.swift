
import UIKit
import SnapKit
import Combine

final class PhotoCell: UICollectionViewCell {
    
    static let id = "photoCell"
    @Published private(set) var action: EXIFAction = .none
    var cancellables = Set<AnyCancellable>()
    
    private let previewView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .systemPink
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    private lazy var differentButton: UIButton = {
        let view = UIButton()
        view.setTitle(String(localized: "Different photo"), for: .normal)
        view.setTitleColor(UIColor(named: "base_violet_color"), for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        view.backgroundColor = UIColor(named: "E1DDFB")
        view.layer.cornerRadius = 48/2
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
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
        cancellables.removeAll()
        action = .none
    }
    private func setupeSubview() {
        contentView.addSubview(previewView)
        contentView.addSubview(differentButton)
    }
    @objc func handleTap(_ sender: UIButton) {
        action = .different_photo
    }
    private func subviewConstraint() {
        previewView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(190)
        }
        differentButton.snp.makeConstraints { make in
            make.top.equalTo(previewView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(15)
        }
    }
    func configure(_ image: UIImage?) {
        previewView.image = image
    }
}
