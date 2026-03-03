import UIKit
import SnapKit
import Combine

class OnboadrViewController: UIViewController {

    private let viewModel = OnboadrViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private var correctIndex: Int = 0
    private var data: AllNecessaryData?
    
    private let backgroundView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    private let logoIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "app_logo")
        view.layer.cornerRadius = 40
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        return view
    }()
    private var headerTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = .black
        view.font = .systemFont(ofSize: 40, weight: .bold)
        view.numberOfLines = 0
        return view
    }()
    private var descriptionTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor(named: "5E616E")
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.numberOfLines = 0
        return view
    }()
    private lazy var continueButton: UIButton = {
        let view = UIButton()
        view.setTitle(String(localized: "Continue"), for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        view.backgroundColor = UIColor(named: "base_violet_color")
        view.layer.cornerRadius = 48/2
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white       
        setupUI()
        setupConstraints()
        
        setupBindings()

        viewModel.showLogo(logoIconView)
        viewModel.didStartOnboard = { [weak self] in
            if AppData.hasOnboardingCompleted == false {
                UIView.animate(withDuration: 0.3) { [weak self] in guard let self else { return }
                    continueButton.alpha = 1.0
                    headerTitle.text = viewModel.data[correctIndex].headerText
                    descriptionTitle.text = viewModel.data[correctIndex].descriptionText
                    backgroundView.image = viewModel.data[correctIndex].backgroundImage
                    
                }
            } else {
                self?.viewModel.checkAuthorizationStatus()
            }
        }
    }
}
private extension OnboadrViewController {
    func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(headerTitle)
        view.addSubview(descriptionTitle)
        view.addSubview(continueButton)
        continueButton.alpha = 0.0
        
        view.addSubview(logoIconView)
    }
    func setupConstraints() {
        logoIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(150)
        }
        headerTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.greaterThanOrEqualTo(45)
        }
        descriptionTitle.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.greaterThanOrEqualTo(25)
        }
        backgroundView.snp.makeConstraints { make in
//            make.top.equalTo(descriptionTitle.snp.bottom).offset(20)
            make.top.equalToSuperview().inset(300)
            make.bottomMargin.leading.trailing.equalToSuperview()
        }
        continueButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.bottomMargin.equalToSuperview().inset(15)
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        viewModel.clickAnimate(continueButton)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in guard let self else { return }
            correctIndex += 1
            if correctIndex >= viewModel.data.count {
                openPaywall()
                return }
            headerTitle.text = viewModel.data[correctIndex].headerText
            descriptionTitle.text = viewModel.data[correctIndex].descriptionText
            backgroundView.image = viewModel.data[correctIndex].backgroundImage
            switch correctIndex {
            case 1:
                viewModel.checkAuthorizationStatus()
            case 2:
                break
            case 3:
                break
            default: break
            }
        }
    }
}
// MARK: - State Change
private extension OnboadrViewController {
    func setupBindings() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.viewModel.checkAuthorizationStatus()
            }
            .store(in: &cancellables)
    }
    func handleStateChange(_ state: LoaderState) {
        switch state {
        case .loading: break
        case .completed(let data):
            self.data = data
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in guard let self else { return }
                if AppData.hasOnboardingCompleted == true {
                    openBaseView(data)
                }
            }
        case .apiError(let error), .error(let error):
            print("error \(error)")
            AlertManager.shared.showError(self,
                                          message: "",
                                          onRetry: { [weak self] in self?.viewModel.checkAuthorizationStatus() },
                                          onSkip: { [weak self] in self?.openBaseView(nil) })
        case .locationDenied:
            AlertManager.shared.showLocationDenied(self,
                                                   onSettings: { [weak self] in self?.viewModel.openAppSettings() })
//            AlertManager.shared.showLocationDenied(self,
//                                                   onSettings: { [weak self] in self?.viewModel.openAppSettings() },
//                                                   onDefault: { [weak self] in self?.viewModel.defaultLocation() })
        default: break
        }
    }
    private func openBaseView(_ data: AllNecessaryData?) {
        if AppData.hasOnboardingCompleted == true {
            showController(BaseViewController(data: data))
        }
    }
    private func openPaywall() {
        let vc = PaywallViewController()
        vc.data = self.data
        showController(vc)
    }
   private func showController(_ controller: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.setViewControllers([controller], animated: false)
    }
}
