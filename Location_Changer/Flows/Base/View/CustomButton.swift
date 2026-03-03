
import UIKit
import SnapKit

class CustomButton: UIButton {
    
    var didTap: (() -> Void)?
    
    let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    init(_ icon: UIImage?) {
        super.init(frame: .zero)
        iconView.image = icon
        
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 15
        
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(15)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    @objc func handleTap(_ sender: UIButton) {
        didTap?()
    }
}
