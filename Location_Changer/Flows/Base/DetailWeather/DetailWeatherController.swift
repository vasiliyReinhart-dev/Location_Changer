import UIKit
import SnapKit
import SDWebImage
import CoreLocation

class DetailWeatherController: UIViewController {

    private let viewModel = BaseViewModel.shared
    private var sunsetView = SunsetView(state: .sunset)
    private var sunriseView = SunsetView(state: .sunrise)
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private var temperatureTitle: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .right
        view.font = .systemFont(ofSize: 64, weight: .bold)
        return view
    }()
    private var adressTitle: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(named: "5E616E")
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 22, weight: .regular)
        return view
    }()
    private var infoTitle: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        return view
    }()
    private lazy var syncButton: UIButton = {
        let view = UIButton()
        view.setTitle(String(localized: "Sync with fake GPS"), for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        view.backgroundColor = UIColor(named: "base_violet_color")
        view.layer.cornerRadius = 48/2
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return view
    }()
    init(data: AllNecessaryData?) {
        super.init(nibName: nil, bundle: nil)
        let tempValue = data?.weather?.current?.tempC ?? 0.0
        if let icon = data?.weather?.current?.condition?.icon {
            let url = String(format: "%@%@",
                             "https:", icon)
            iconView.sd_setImage(with: URL(string: url))
        }
        temperatureTitle.text = String(format: "%d°", Int(tempValue))
        
        let astro = data?.weather?.forecast?.forecastday?.first?.astro
        
        sunsetView = SunsetView(state: .sunset, data: astro)
        sunriseView = SunsetView(state: .sunrise, data: astro)

        
        if let placemark = data?.placemark {
            let city = placemark.locality
            adressTitle.text = city
        }
        infoTitle.text = data?.weather?.current?.condition?.text
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
                        
        setupUI()
        setupConstraints()
    }
}
private extension DetailWeatherController {
    func setupUI() {
        view.addSubview(temperatureTitle)
        view.addSubview(iconView)
        view.addSubview(adressTitle)
        view.addSubview(infoTitle)
        
        view.addSubview(sunsetView)
        view.addSubview(sunriseView)
        
        view.addSubview(syncButton)
    }
    func setupConstraints() {
        temperatureTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.height.equalTo(70)
            make.left.equalTo(15)
            make.right.equalTo(view.snp.centerX)
        }
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(25)
            make.height.width.equalTo(45)
            make.left.equalTo(view.snp.centerX)
        }
        adressTitle.snp.makeConstraints { make in
            make.top.equalTo(temperatureTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(25)
        }
        infoTitle.snp.makeConstraints { make in
            make.top.equalTo(adressTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(22)
        }
        sunsetView.snp.makeConstraints { make in
            make.top.equalTo(infoTitle.snp.bottom).offset(20)
            make.left.equalTo(15)
            make.right.equalTo(infoTitle.snp.centerX).offset(-10)
            make.bottom.equalTo(sunriseView.snp.bottom)
        }
        sunriseView.snp.makeConstraints { make in
            make.top.equalTo(infoTitle.snp.bottom).offset(20)
            make.right.equalToSuperview().inset(15)
            make.left.equalTo(infoTitle.snp.centerX).offset(-0)
        }
        syncButton.snp.makeConstraints { make in
            make.top.equalTo(sunriseView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(15)
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        viewModel.clickAnimate(syncButton)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
