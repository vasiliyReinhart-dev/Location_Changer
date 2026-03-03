import UIKit
import SnapKit
import Combine

final class ProductCell: UICollectionViewCell {
    
    static let id = "produstCell"
    @Published private(set) var action: PaywallAction = .none
    private var products: [PaywallProduct] = []
    var cancellables = Set<AnyCancellable>()
    
    private let productStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.distribution = .fillEqually
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupeSubview()
        subviewConstraint()
        contentView.backgroundColor = UIColor(named: "base_violet_color")
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
        contentView.addSubview(productStack)
    }
    private func subviewConstraint() {
        productStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(25)
        }
    }
    func configureCell(_ data: [PaywallProduct]) {
        products = data
        productStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        data.enumerated().forEach { index, product in
            let view = ProductView()
            view.configure(product)
            view.productButton.tag = index
            view.isSelected = (index == 0)
            view.productButton.addTarget(self, action: #selector(select_product), for: .touchUpInside)
            productStack.addArrangedSubview(view)
        }
    }
    @objc func select_product(_ sender: UIButton) {
        let stack = productStack.arrangedSubviews.compactMap { $0 as? ProductView }
        stack.forEach { view in let selected = (view.productButton.tag == sender.tag)
            view.isSelected = selected
        }
        action = .selectProduct(products[sender.tag])
    }
}
