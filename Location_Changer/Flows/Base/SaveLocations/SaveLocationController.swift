import UIKit
import SnapKit

enum EditMenu: CaseIterable {
    case show_point, edit, remove
    
    var name: String? {
        switch self {
        case .show_point: return String(localized: "Show point")
        case .edit: return String(localized: "Edit")
        case .remove: return String(localized: "Remove")
        }
    }
    var icon: UIImage? {
        switch self {
        case .show_point: return UIImage(systemName: "map")
        case .edit: return UIImage(systemName: "pencil.line")
        case .remove: return UIImage(systemName: "trash")
        }
    }
    var attributes: UIMenuElement.Attributes {
        switch self {
        case .remove: return .destructive
        default: return []
        }
    }
}

class SaveLocationController: UIViewController {

    private let viewModel = BaseViewModel.shared
    private var data: [LocationSaveData]? {
        didSet { collectionView.reloadData() }
    }
    var didSelectLocation: ((_ data: LocationSaveData?, _ edit: Bool) -> Void)?
    private let emptyView = EmptyLocationView()
    
    private var headerTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 22, weight: .bold)
        view.text = String(localized: "Saved location")
        return view
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero,
                                    collectionViewLayout: layout)
        view.contentMode = .scaleAspectFill
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        view.register(LocationCell.self,
                      forCellWithReuseIdentifier: "locationCell")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        data = StorageManager.shared.getAllLocation()
        emptyView.isHidden = !(data?.isEmpty == true)
    }
    private func makeEditMenu(_ indexPath: IndexPath) -> UIMenu {
        let actions = EditMenu.allCases.map { item in
            UIAction(title: item.name ?? "",
                     image: item.icon,
                     attributes: item.attributes) { [weak self] _ in
                let data = self?.data?[indexPath.item]
                switch item {
                case .show_point:
                    self?.dismiss(animated: true) {
                        self?.didSelectLocation?(data, false)
                    }
                case .edit:
                    self?.dismiss(animated: true) {
                        self?.didSelectLocation?(data, true)
                    }
                case .remove:
                    let alert = UIAlertController(title: String(localized: "Are you sure you want to remove this location?"), message: "",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: String(localized: "Remove location"),
                                                  style: .destructive) { _ in
                        StorageManager.shared.removeLocationData([data?.uuid ?? ""])
                        self?.data = StorageManager.shared.getAllLocation()
                        if self?.data?.isEmpty == true {
                            self?.dismiss(animated: true)
                        }
                    })
                    alert.addAction(UIAlertAction(title: String(localized: "Cancel"),
                                                  style: .default) { _ in})
                    self?.present(alert, animated: true)
                }
            }
        }
        return UIMenu(preferredElementSize: .large,
                      children: actions)
    }
}
private extension SaveLocationController {
    func setupUI() {
        view.addSubview(headerTitle)
        view.addSubview(collectionView)
        
        view.addSubview(emptyView)
    }
    func setupConstraints() {
        headerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(24)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview().inset(15)
        }
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(collectionView)
        }
    }
}
extension SaveLocationController: UICollectionViewDelegateFlowLayout,
                                  UICollectionViewDelegate,
                                  UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        data?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell",
                                                           for: indexPath) as? LocationCell,
                let data = data?[indexPath.item] else { return UICollectionViewCell() }
        cell.configureCell(data)
        cell.editButton.menu = makeEditMenu(indexPath)
        cell.editButton.showsMenuAsPrimaryAction = true
        return cell
    }
//    func collectionView(_ collectionView: UICollectionView,
//                        didSelectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
//        viewModel.clickAnimate(cell)
//        let data = data?[indexPath.item]
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
////            self?.didSelectLocation?(data, false)
//        }
//    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: 300)
    }
}
