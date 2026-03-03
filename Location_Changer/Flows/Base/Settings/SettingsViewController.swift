import UIKit
import SnapKit
import Combine
import MessageUI
import SafariServices

class SettingsViewController: UIViewController {

    private let viewModel = BaseViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private var settingsData: [SettingsData] = [] {
        didSet { collectionView.reloadData() }
    }
    
    private var headerTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 22, weight: .bold)
        view.text = String(localized: "Settings")
        return view
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.register(SettingsCell.self, forCellWithReuseIdentifier: SettingsCell.identifier)
        view.register(SettingsHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SettingsHeaderView.identifier)
        view.delegate = self
        view.dataSource = self
        return view
   }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsData = viewModel.getSettingsData()
    }
}
private extension SettingsViewController {
    func setupUI() {
        view.addSubview(headerTitle)
        view.addSubview(collectionView)
    }
    func setupConstraints() {
        headerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(65)
            make.leading.trailing.equalToSuperview().inset(60)
            make.height.equalTo(25)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom)
            make.leading.trailing.bottomMargin.equalToSuperview()
        }
    }
}
extension SettingsViewController: UICollectionViewDelegateFlowLayout,
                                  UICollectionViewDelegate,
                                  UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        settingsData.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        settingsData[section].entity.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "SettingsHeaderView",
                                                                           for: indexPath) as? SettingsHeaderView else { return UICollectionReusableView() }
        header.headerTitle.text = settingsData[indexPath.section].header
        return header
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingsCell",
                                                            for: indexPath) as? SettingsCell else { return UICollectionViewCell() }
        let data = settingsData[indexPath.section].entity[indexPath.item]
        cell.configuresView(data)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SettingsCell {
            let data = settingsData[indexPath.section].entity[indexPath.item]
            viewModel.clickAnimate(cell)
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.4) { [weak self] in guard let self  else { return }
                switch data {
                case .banner: openPaywall()
                case .manage_plan:
                    if AppData.premiumAccess == false {
                        openPaywall()
                    } else {
                        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                case .gps_accuracy: break
                case .support: support()
                case .restore:
                    cell.cellIconImage.isHidden = true
                    cell.loader.startAnimating()
                    viewModel.restore()
                    viewModel.subscribeToStatus()
                    setupBindings()
                case .terms_privacy:
                    AlertManager.shared.openLink(self,
                                                 terms: { [weak self] in self?.openURL(Links.terms.rawValue) },
                                                 privacy: { [weak self] in self?.openURL(Links.privacy.rawValue) })
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let defaultHeight: CGFloat = 48
        let bannerHeight: CGFloat = 208
        if AppData.premiumAccess == false {
            if indexPath.section == 0 && indexPath.item == 0 {
                return CGSize(width: width, height: bannerHeight)
            }
        }
        return CGSize(width: width, height: defaultHeight)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10,
                            left: 15,
                            bottom: 10,
                            right: 15)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: 30)
    }
}
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    private func openPaywall() {
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(PaywallViewController(), animated: false)
    }
    func openURL(_ url: String) {
        if let url = URL(string: url) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.modalPresentationStyle = .overFullScreen
            present(safariVC, animated: true)
        }
    }
    private func support() {
        if MFMailComposeViewController.canSendMail() {
            let view = MFMailComposeViewController()
            view.mailComposeDelegate = self
            view.setToRecipients([AppData.email])
            view.setSubject("Contact support")
            let messageBody = """
            \(String(localized: "Please don't delete it")): 
            ┌────────────────────────────
            │ app version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
            │ user id: \(AppData.apphud_user_id)
            └─────────────────────────────
            \(String(localized: "write below")) ↓
            
            
            
            
            """
            view.setMessageBody(messageBody, isHTML: false)
            present(view, animated: true)
        } else {
            print("sentMessage Error")
        }
    }
    func mailComposeController( _ controller: MFMailComposeViewController,
                                didFinishWith result: MFMailComposeResult,
                                error: Error?) {
        switch result {
        case .cancelled:
            print("Письмо отменено")
        case .saved:
            print("Письмо сохранено в черновики")
        case .sent:
            print("Письмо отправлено")
        case .failed:
            print("Ошибка отправки: \(error?.localizedDescription ?? "")")
        @unknown default: break
        }
        controller.dismiss(animated: true)
    }
}
private extension SettingsViewController {
    func setupBindings() {
        viewModel.$subscriptionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleStatusChange(status)
            }
            .store(in: &cancellables)
    }
    private func handleStatusChange(_ status: SubscriptionStatus) {
        switch status {
        case .subdscribed(_), .restored:
            settingsData = viewModel.getSettingsData()
        case .errorRestore, .notRestored:
            AlertManager.shared.showRestoreError(self)
            collectionView.reloadData()
        case .notSubscribed:
            collectionView.reloadData()
        default: break
        }
    }
}
