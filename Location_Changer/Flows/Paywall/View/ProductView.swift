import UIKit
import SnapKit

class ProductView: UIView {
    
    var isSelected: Bool = false {
        didSet {
            selectIcon.image = isSelected ? UIImage(named: "select_image"): UIImage(named: "no_select_image")
            productButton.backgroundColor = isSelected ? .white : UIColor(named: "base_violet_color")
            productButton.layer.borderColor = isSelected ? UIColor.clear.cgColor : UIColor(named: "9DA0AE")?.cgColor
            priceLabel.textColor = isSelected ? .black : .white
            productTitle.textColor = isSelected ? UIColor(named: "9DA0AE") : .white.withAlphaComponent(0.7)
        }
    }
    var productButton: UIButton = {
        let view = UIButton()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 2.0
        view.backgroundColor = .white
        return view
    }()
    private let priceLabel: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17, weight: .regular)
        return view
    }()
    private let productTitle: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(named: "9DA0AE")
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 11, weight: .regular)
        return view
    }()
    private let selectIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private let discountView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let discountBackgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 10
        return layer
    }()
    private let discountTitle: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(named: "base_violet_color")
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 11, weight: .semibold)
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    private func setupView() {
        backgroundColor = .clear
        addSubview(productButton)
        productButton.addSubview(priceLabel)
        productButton.addSubview(selectIcon)
        productButton.addSubview(productTitle)
        
        addSubview(discountView)
        discountView.layer.insertSublayer(discountBackgroundLayer, at: 0) // Кладем ПОД текст
        discountView.addSubview(discountTitle)
        
        setupConstraints()
    }
    private func setupConstraints() {
        productButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(61)
        }
        selectIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
            make.left.equalTo(15)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.left.equalTo(selectIcon.snp.right).offset(10)
            make.right.equalToSuperview().inset(15)
            make.bottom.equalTo(productButton.snp.centerY)
        }
        productTitle.snp.makeConstraints { make in
            make.top.equalTo(productButton.snp.centerY)
            make.left.equalTo(selectIcon.snp.right).offset(10)
            make.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(5)
        }
        discountView.snp.makeConstraints { make in
            make.top.equalTo(productButton.snp.top)
            make.right.equalTo(productButton.snp.right)
            make.height.equalTo(21)
        }
        discountTitle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = discountView.bounds
        guard bounds.width > 0 else { return }
        let radius: CGFloat = 25
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        path.addLine(to: CGPoint(x: radius, y: bounds.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: bounds.height - radius),
                          controlPoint: CGPoint(x: 0, y: bounds.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.width - radius, y: 0))
        path.addQuadCurve(to: CGPoint(x: bounds.width, y: radius),
                          controlPoint: CGPoint(x: bounds.width, y: 0))
        path.close()
        discountBackgroundLayer.frame = discountView.bounds
        discountBackgroundLayer.path = path.cgPath
        discountBackgroundLayer.shadowPath = path.cgPath // Тень по форме пути
    }
    func configure(_ product: PaywallProduct) {
        guard let price = product.price,
              let currency = product.currency else { return }
        priceLabel.text = String(format: "%@ %@ %@%@",
                                 String(localized: "Just"),
                                 currency + price.filter { char in char.isNumber || char == "." || char == "," },
                                 "/",
                                 product.subscriptionPeriod?.name ?? "")
        productTitle.text = String(localized: "Auto renewable. Cancel anytime.")
        switch product.subscriptionPeriod ?? .none {
        case .week:
            discountTitle.text = String(format: "%@ %@",
                                       String(localized: "SAVE"),
                                       "40%")
        case .month:
            discountTitle.text = String(format: "%@ %@",
                                       String(localized: "SAVE"),
                                       "40%")
        case .year:
            discountTitle.text = String(format: "%@ %@",
                                       String(localized: "SAVE"),
                                       "70%")
        default: break
        }
        discountView.isHidden = (product.subscriptionPeriod == .none)
    }
}
