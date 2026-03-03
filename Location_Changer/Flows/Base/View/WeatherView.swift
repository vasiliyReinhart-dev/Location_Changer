import UIKit
import SnapKit
import SDWebImage

class WeatherView: UIButton {
    
    var didTap: (() -> Void)?
    private let loader = UIActivityIndicatorView()
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private var temperatureTitle: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 16, weight: .semibold)
        return view
    }()
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 15
        layer.cornerRadius = 23
        
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        addSubview(iconView)
        addSubview(temperatureTitle)
        addSubview(loader)
        loader.color = .black
        
        iconView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY)
            make.width.height.equalTo(25)
        }
        temperatureTitle.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.centerY)
            make.leading.trailing.equalToSuperview().inset(5)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
        loader.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func setupeData(_ data: Current?) {
        let tempValue = data?.tempC ?? 0.0
        if let icon = data?.condition?.icon {
            let url = String(format: "%@%@",
                             "https:", icon)
            iconView.sd_setImage(with: URL(string: url))
        }
        temperatureTitle.text = String(format: "%d°", Int(tempValue))
    }
    @objc func handleTap(_ sender: UIButton) {
        didTap?()
    }
    func reloadData(_ bool: Bool) {
        isUserInteractionEnabled = !bool
        bool ? loader.startAnimating() : loader.stopAnimating()
        iconView.isHidden = bool
        temperatureTitle.isHidden = bool
    }
}
