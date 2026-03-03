import UIKit
import SnapKit
import Combine
import ApphudSDK
import SafariServices

class PaywallViewController: UIViewController {

    private let viewModel = PaywallViewModel.shared
    private let loader = UIActivityIndicatorView()
    private var cancellables = Set<AnyCancellable>()
    private var selectProduct: ApphudProduct?
    var data: AllNecessaryData?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width,
                                          height: 100)
        layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        let view = UICollectionView(frame: .zero,
                                    collectionViewLayout: layout)
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.register(HeaderCell.self,
                      forCellWithReuseIdentifier: HeaderCell.id)
        view.register(ProductCell.self,
                      forCellWithReuseIdentifier: ProductCell.id)
        view.register(InfoCell.self,
                      forCellWithReuseIdentifier: InfoCell.id)
        view.delegate = self
        view.dataSource = self
        view.contentInset.top = -50
        return view
   }()
    private var conteinerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private lazy var accessButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle(String(localized: "Unlock access"), for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        view.backgroundColor = UIColor(named: "base_violet_color")
        view.layer.cornerRadius = 48/2
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        view.backgroundColor = UIColor(named: "base_violet_color")
        setupUI()
        setupConstraints()
        viewModel.subscribeToStatus()
        setupBindings()
    }
}
private extension PaywallViewController {
    func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(conteinerView)
        conteinerView.addSubview(accessButton)
        accessButton.addSubview(loader)
        loader.color = .white
    }
    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(conteinerView.snp.top)
        }
        conteinerView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        accessButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.bottomMargin.equalToSuperview().inset(15)
        }
        loader.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15)
        }
    }
    func closeView() {
        if AppData.hasOnboardingCompleted == true {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .fade
            navigationController?.view.layer.add(transition, forKey: kCATransition)
            navigationController?.popViewController(animated: false)
        } else {
            AppData.hasOnboardingCompleted = true
            showController(BaseViewController(data: data))
        }
    }
    private func showController(_ controller: UIViewController) {
         let transition = CATransition()
         transition.duration = 0.4
         transition.type = .fade
         transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
         navigationController?.view.layer.add(transition, forKey: kCATransition)
         navigationController?.setViewControllers([controller], animated: false)
     }
    @objc func handleTap(_ sender: UIButton) {
        viewModel.clickAnimate(accessButton)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in guard let self else { return }
            startSubscription()
        }
    }
    func setupBindings() {
        viewModel.$products
                .receive(on: DispatchQueue.main)
                .sink { [weak self] products in
                    guard let self = self else { return }
                    if self.selectProduct == nil {
                        self.selectProduct = products.first?.original
                    }
                    self.reloadCollection()
                }
                .store(in: &cancellables)
        viewModel.$subscriptionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleStatusChange(status)
            }
            .store(in: &cancellables)
    }
    func handleAcrion(_ state: PaywallAction) {
        switch state {
        case .close:
            closeView()
        case .selectProduct(let product):
            self.selectProduct = product?.original
        case .restore:
            viewModel.restore()
        case .openLink(let link):
            if let url = URL(string: link.rawValue) {
                let safariVC = SFSafariViewController(url: url)
                safariVC.modalPresentationStyle = .overFullScreen
                present(safariVC, animated: true)
            }
        default: break
        }
    }
    private func handleStatusChange(_ status: SubscriptionStatus) {
        accessButton.isUserInteractionEnabled = true
        loader.stopAnimating()
        switch status {
        case .subdscribed(_), .restored:
            closeView()
        case .errorSubscribed:
            AlertManager.shared.showSubscriptionError(self,
                                                      tryAgain: { [weak self] in
                self?.startSubscription()
            })
        case .errorRestore, .notRestored:
            AlertManager.shared.showRestoreError(self)
            reloadCollection()
        case .notSubscribed:
            reloadCollection()
            print("notSubscribed")
        default: break
        }
    }
    private func startSubscription() {
        accessButton.isUserInteractionEnabled = false
        loader.startAnimating()
        viewModel.purchase(selectProduct)
    }
    func reloadCollection() {
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems.filter { $0.item != 1 })
    }
}
extension PaywallViewController: UICollectionViewDelegateFlowLayout,
                                 UICollectionViewDelegate,
                                 UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let sectionType = viewModel.sections[section]
        if sectionType == .product {
            return 1
        }
        return sectionType.items.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = viewModel.sections[indexPath.section]
        let item = sectionType.items[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseID,
                                                      for: indexPath)
        item.configure(cell: cell,
                       data: viewModel.paywallData) { [weak self] action in
            self?.handleAcrion(action)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
        let width = collectionView.bounds.width - sectionInset.left - sectionInset.right
        return CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
    }
}
