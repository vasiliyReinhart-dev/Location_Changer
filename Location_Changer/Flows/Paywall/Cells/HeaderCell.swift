import UIKit
import SnapKit
import Combine

final class HeaderCell: UICollectionViewCell {
    
    static let id = "headerCell"
    
    private var conteinerView = UIView()
    @Published private(set) var action: PaywallAction = .none
    var cancellables = Set<AnyCancellable>()
    
    private let logoIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "app_logo")
        view.layer.cornerRadius = 20
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    private let logoShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 15
        return view
    }()
    private var headerTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = .white
        view.font = .systemFont(ofSize: 22, weight: .bold)
        view.numberOfLines = 0
        return view
    }()
    private var descriptionTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = .white
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.numberOfLines = 0
        return view
    }()
    private lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setBackgroundImage(UIImage(named: "close_view_icon"), for: .normal)
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupeSubview()
        subviewConstraint()
        conteinerView.backgroundColor = UIColor(named: "base_violet_color")
//        if AppData.hasOnboardingCompleted == true {
//            closeButton.isHidden = true
//        }
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width,
                                height: 0)
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
        contentView.addSubview(conteinerView)
    
        conteinerView.addSubview(logoShadowView)
        logoShadowView.addSubview(logoIconView)
        conteinerView.addSubview(headerTitle)
        conteinerView.addSubview(descriptionTitle)
        conteinerView.addSubview(closeButton)
    }
    private func subviewConstraint() {
        conteinerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.right.equalToSuperview().inset(15)
            make.width.height.equalTo(32)
        }
        logoShadowView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(15)
            make.width.height.equalTo(100)
        }
        logoIconView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerTitle.snp.makeConstraints { make in
            make.top.equalTo(logoIconView.snp.bottom).offset(20)
            make.height.greaterThanOrEqualTo(20)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        descriptionTitle.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom).offset(10)
            make.height.greaterThanOrEqualTo(20)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        action = .close
    }
    func configureCell(header: String?,
                       description: String?) {
        headerTitle.text = header
        descriptionTitle.text = description 
    }
}
