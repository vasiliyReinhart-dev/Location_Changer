import UIKit
import SnapKit

class EmptyLocationView: UIView {
    
    private let emptyImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "empty_image")
        return view
    }()
    private var emptyTitle: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(named: "0B0C0F")
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.text = String(localized: "You don’t have any saved \nlocations yet")
        view.numberOfLines = 2
        return view
    }()
    init() {
        super.init(frame: .zero)
        
        addSubview(emptyImageView)
        addSubview(emptyTitle)
        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        emptyTitle.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(50)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
