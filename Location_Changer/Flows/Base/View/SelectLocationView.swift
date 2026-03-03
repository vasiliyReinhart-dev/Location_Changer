import UIKit
import SnapKit
import CoreLocation

class SelectLocationView: UIView {
    
    enum ViewState {
        case select(CLPlacemark?)
        case no_select
    }
    var removeLocation: (() -> Void)?
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12/2
        return view
    }()
    private lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setBackgroundImage(UIImage(named: "x_icon_2"), for: .normal)
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        view.alpha = 0
        return view
    }()
    private var headerTitle: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(named: "0B0C0F")
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        return view
    }()
    private var locationTitle: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(named: "5E616E")
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 12, weight: .regular)
        view.numberOfLines = 0
        view.alpha = 0
        return view
    }()
    init(_ state: ViewState) {
        super.init(frame: .zero)
        setupBaseLayer()
        setupUI()
        setupConstraints()
        setupeState(state)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func setupeState(_ state: ViewState) {
        switch state {
        case .select(let placemark):
            closeButton.isHidden = false
            if let placemark = placemark {
                let city = placemark.locality
                let country = placemark.country
                let street = placemark.thoroughfare
                locationTitle.text = String(format: "%@ %@ %@",
                                            country ?? "",
                                            city ?? "",
                                            street ?? "")
            }
            indicatorView.backgroundColor = UIColor(named: "34C759")
            headerTitle.text = String(localized: "Location selected")
            headerTitle.snp.remakeConstraints { make in
                make.top.equalToSuperview().inset(12)
                make.left.equalTo(indicatorView.snp.right).offset(10)
                make.right.equalTo(closeButton.snp.left).offset(-5)
            }
            locationTitle.snp.remakeConstraints { make in
                make.top.equalTo(headerTitle.snp.bottom).offset(4)
                make.left.right.equalTo(headerTitle)
                make.bottom.equalToSuperview().inset(12)
            }
        case .no_select:
            indicatorView.backgroundColor = UIColor(named: "C7C7CC")
            headerTitle.text = String(localized: "Location not hidden")
            headerTitle.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(indicatorView.snp.right).offset(10)
                make.right.equalToSuperview().inset(15)
                make.height.equalTo(44)
            }
            locationTitle.snp.remakeConstraints { make in
                make.top.equalTo(headerTitle.snp.bottom)
                make.left.right.equalTo(headerTitle)
                make.height.equalTo(0)
                make.bottom.equalToSuperview().inset(0)
            }
        }
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) { [weak self] in guard let self = self else { return }
            switch state {
            case .select:
                self.locationTitle.alpha = 1.0
                self.closeButton.alpha = 1.0
            case .no_select:
                self.locationTitle.alpha = 0.0
                self.closeButton.alpha = 0.0
            }
            self.layoutIfNeeded()
            
        } completion: { [weak self] finished in
            if finished, case .no_select = state {
                self?.closeButton.isHidden = true
            }
        }
    }
}
private extension SelectLocationView {
    func setupBaseLayer() {
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 10
        layer.cornerRadius = 15
    }
    func setupUI() {
        addSubview(indicatorView)
        addSubview(headerTitle)
        addSubview(locationTitle)
        addSubview(closeButton)
    }
    func setupConstraints() {
        indicatorView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.width.height.equalTo(12)
        }
        headerTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(indicatorView.snp.right).offset(10)
            make.right.equalToSuperview().inset(45)
            make.height.equalTo(44)
        }
        closeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
            make.width.height.equalTo(32)
        }
        locationTitle.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom)
            make.left.right.equalTo(headerTitle)
            make.height.equalTo(0)
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        setupeState(.no_select)
        removeLocation?()
    }
}
