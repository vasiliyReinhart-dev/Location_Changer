
import UIKit
import SnapKit

@MainActor
class SunsetView: UIView {
    
    enum ViewState {
        case sunset, sunrise
        var title: String? {
            switch self {
            case .sunset: return String(localized: "Sunset")
            case .sunrise: return String(localized: "Sunrise")
            }
        }
        var icon: UIImage? {
            switch self {
            case .sunset: return UIImage(named: "sunset_icon")
            case .sunrise: return UIImage(named: "sunrise_icon")
            }
        }
    }
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private var title: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(named: "0B0C0F")
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        return view
    }()
    private var timeTitle: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(named: "0B0C0F")
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 16, weight: .regular)
        return view
    }()
    init(state: ViewState, data: Astro? = nil) {
        super.init(frame: .zero)
        backgroundColor = UIColor(named: "F2F6F9")
        layer.cornerRadius = 16
        iconView.image = state.icon
        title.text = state.title
        
        switch state {
        case .sunset: timeTitle.text = data?.sunset
        case .sunrise: timeTitle.text = data?.sunrise
        }
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
private extension SunsetView {
    func setupUI() {
        addSubview(iconView)
        addSubview(title)
        addSubview(timeTitle)
    }
    func setupConstraints() {
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(48)
        }
        title.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(10)
            make.height.equalTo(20)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        timeTitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(18)
        }
    }
}
