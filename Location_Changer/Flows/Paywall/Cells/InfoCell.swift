import UIKit
import SnapKit
import Combine

final class InfoCell: UICollectionViewCell {
    
    static let id = "infoCell"
    @Published private(set) var action: PaywallAction = .none
    var cancellables = Set<AnyCancellable>()
    private let bottons = [String(localized: "Privacy Policy"),
                           String(localized: "Restore Purchases"),
                           String(localized: "Privacy Policy")]
    private let loader = UIActivityIndicatorView()
    
    private var conteinerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .clear
        return view
    }()
    private let infoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 15
        view.distribution = .fill
        view.alignment = .fill
        return view
    }()
    private let buttonStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 10
        view.alignment = .center
        view.distribution = .fillEqually
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupeSubview()
        subviewConstraint()
        
        conteinerView.backgroundColor = .white
        setupeButton()
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
        contentView.addSubview(conteinerView)
        conteinerView.addSubview(infoStack)
        contentView.addSubview(buttonStack)
        contentView.addSubview(loader)
        loader.color = .white
    }
    private func subviewConstraint() {
        conteinerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        infoStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(conteinerView.snp.bottom)
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
        loader.snp.makeConstraints { make in
            make.center.equalTo(buttonStack)
        }
    }
   private func setupeButton() {
       buttonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
       bottons.enumerated().forEach { index, data in
           let view = UIButton()
            view.setTitle(data, for: .normal)
            view.titleLabel?.font = .systemFont(ofSize: 11, weight: .regular)
            view.setTitleColor(.white, for: .normal)
            view.tag = index
            view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
            buttonStack.addArrangedSubview(view)
        }
    }
    @objc private func handleTap(_ sender: UIButton) {
        switch sender.tag {
        case 0: action = .openLink(.privacy)
        case 1: action = .restore
            loader.startAnimating()
            buttonStack.isHidden = true
        case 2: action = .openLink(.terms)
        default: break
        }
    }
    func configureCell(_ data: [PaywallInfoData]) {
        loader.stopAnimating()
        buttonStack.isHidden = false
        infoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        data.enumerated().forEach { index, info in
            let view = PaywallInfoView()
            view.setupeInfo(info)
            infoStack.addArrangedSubview(view)
        }
    }
}
