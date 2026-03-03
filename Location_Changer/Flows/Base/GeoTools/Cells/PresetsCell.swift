import UIKit
import SnapKit
import Combine

final class PresetsCell: UICollectionViewCell {
    
    static let id = "presetsCell"
    private var selectIndexPath: IndexPath?
    @Published private(set) var action: EXIFAction = .none
    var cancellables = Set<AnyCancellable>()
    
    private var headerTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        view.text = String(localized: "Presets")
        return view
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let view = UICollectionView(frame: .zero,
                                    collectionViewLayout: layout)
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.register(PresetsSelectCell.self, forCellWithReuseIdentifier: PresetsSelectCell.id)
        view.delegate = self
        view.dataSource = self
        return view
   }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupeSubview()
        subviewConstraint()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in guard let self else { return }
            selectIndexPath = IndexPath(row: 3, section: 0)
            if let selectIndexPath = selectIndexPath {
                collectionView.scrollToItem(at: selectIndexPath,
                                            at: .right,
                                            animated: true)
            }
            collectionView.reloadData()
        }
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let size = contentView.systemLayoutSizeFitting(targetSize,
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .fittingSizeLevel)
        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
        action = .none
        selectIndexPath = nil
        collectionView.setContentOffset(.zero, animated: false)
    }
    private func setupeSubview() {
        contentView.addSubview(headerTitle)
        contentView.addSubview(collectionView)
    }
    private func subviewConstraint() {
        headerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(15)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(20)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(160)
            make.bottom.equalToSuperview().inset(15)
        }
    }
    func configure(_ data: EXIFData) {
        if data.presets == .Own {
            if let selectIndexPath = selectIndexPath {
                collectionView.scrollToItem(at: selectIndexPath,
                                            at: .right,
                                            animated: true)
            }
        }
    }
}
extension PresetsCell: UICollectionViewDelegateFlowLayout,
                       UICollectionViewDelegate,
                       UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        Presets.allCases.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetsSelectCell.id,
                                                           for: indexPath) as? PresetsSelectCell else { return UICollectionViewCell() }
        let presets = Presets.allCases[indexPath.row]
        cell.configure(presets, selectIndexPath?.contains(indexPath) ?? false)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        selectIndexPath = nil
        selectIndexPath = indexPath
        action = .select_presets(Presets.allCases[indexPath.row])
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 112,
                      height: collectionView.bounds.height)
    }
}
