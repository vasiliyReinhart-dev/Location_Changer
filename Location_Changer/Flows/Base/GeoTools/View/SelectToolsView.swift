import UIKit
import SnapKit

class SelectToolsView: UIView {
    
    var viewButton: UIButton = {
        let view = UIButton()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor(named: "F2F6F9")
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
    private let arrow: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "arrow_icon")
        return view
    }()
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func setupeData(_ data: GeoTools) {
        icon.image = data.icon
        nameTitle.text = data.name
    }
}
private extension SelectToolsView {
    func setupUI() {
        addSubview(viewButton)
        addSubview(icon)
        addSubview(nameTitle)
        addSubview(arrow)
    }
    func setupConstraints() {
        viewButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(64)
        }
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        nameTitle.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).inset(-10)
            make.centerY.equalToSuperview()
            make.right.equalTo(arrow.snp.left).inset(-10)
        }
        arrow.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15)
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        
    }
}

