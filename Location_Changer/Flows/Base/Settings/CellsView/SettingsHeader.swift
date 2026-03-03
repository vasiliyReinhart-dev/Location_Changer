import UIKit
import SnapKit

final class SettingsHeaderView: UICollectionReusableView {
    
    static let identifier: String = "SettingsHeaderView"
    
    var headerTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerTitle)
        backgroundColor = .clear
        headerTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
