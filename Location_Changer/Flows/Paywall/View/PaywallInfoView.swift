
import UIKit
import SnapKit

class PaywallInfoView: UIView {
    
    private let icon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private let headerTitle: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.numberOfLines = 0
        return view
    }()
    private let descriptionTitle: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.numberOfLines = 0
        return view
    }()
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func setupeInfo(_ data: PaywallInfoData) {
        icon.image = data.icon
        headerTitle.text = data.header
        descriptionTitle.text = data.subscription
    }
}
private extension PaywallInfoView {
    func setupUI() {
        addSubview(icon)
        addSubview(headerTitle)
        addSubview(descriptionTitle)
    }
    func setupConstraints() {
        icon.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.height.equalTo(32)
        }
        headerTitle.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.left.equalTo(icon.snp.right).inset(-10)
        }
        descriptionTitle.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom).offset(5)
            make.right.equalToSuperview()
            make.left.equalTo(icon.snp.right).inset(-10)
            make.bottom.equalToSuperview()
        }
    }
}
