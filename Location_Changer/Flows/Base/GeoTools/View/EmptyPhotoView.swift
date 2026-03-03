
import UIKit
import SnapKit

class EmptyPhotoView: UIView {
    
    private let emptyImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "empty_image_view")
        return view
    }()
    private let emptyBaseTitle: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.text = String(localized: "Edit Photo Metadata")
        return view
    }()
    private let emptyTitle: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.text = String(localized: "Modify location and metadata. Add a photo to start editing")
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
}
private extension EmptyPhotoView {
    func setupUI() {
        addSubview(emptyImageView)
        addSubview(emptyBaseTitle)
        addSubview(emptyTitle)
    }
    func setupConstraints() {
        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            
        }
        emptyBaseTitle.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        emptyTitle.snp.makeConstraints { make in
            make.top.equalTo(emptyBaseTitle.snp.bottom).offset(15)
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(20)
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        
    }
}
