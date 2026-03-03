import UIKit
import SnapKit

final class SettingsCell: UICollectionViewCell {
    
    static let identifier: String = "SettingsCell"
    let loader = UIActivityIndicatorView()
    
    private var conteinerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.backgroundColor = UIColor(named: "767680")
        return view
    }()
    private var settingsTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 16, weight: .semibold)
        view.textColor = .black
        return view
    }()
    var cellIconImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    private lazy var selectView: UISegmentedControl = {
        let view = UISegmentedControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.insertSegment(withTitle: String(localized: "Low"), at: 0, animated: false)
        view.insertSegment(withTitle: String(localized: "Medium"), at: 1, animated: false)
        view.insertSegment(withTitle: String(localized: "High"), at: 2, animated: false)
        view.setTitleTextAttributes([.foregroundColor: UIColor(named: "9DA0AE") as Any,
                                     .font: UIFont.systemFont(ofSize: 13, weight: .regular)],for: .normal)
        view.setTitleTextAttributes([.foregroundColor: UIColor.white,
                                     .font: UIFont.systemFont(ofSize: 13, weight: .semibold)], for: .selected)
        view.selectedSegmentIndex = AppData.selectedGpsAccuracy
        view.selectedSegmentTintColor = UIColor(named: "base_violet_color")
        view.backgroundColor = .clear
        view.addTarget(self, action: #selector(handleChanged), for: .valueChanged)
        view.layer.cornerRadius = 46/2
        view.clipsToBounds = true
        view.backgroundColor = UIColor(named: "767680")
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializationView()
        setupeConstraint()
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configuresView(_ data: SettingsEntities) {
        switch data {
        case .banner:
            cellIconImage.isHidden = false
            selectView.isHidden = true
            settingsTitle.isHidden = true
            conteinerView.backgroundColor = .clear
            cellIconImage.image = data.icon
            cellIconImage.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        case .gps_accuracy:
            conteinerView.isHidden = true
            selectView.isHidden = false
        case .manage_plan, .support, .restore, .terms_privacy:
            cellIconImage.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(10)
                make.width.height.equalTo(32)
            }
            settingsTitle.isHidden = false
            cellIconImage.isHidden = false
            conteinerView.isHidden = false
            selectView.isHidden = true
            conteinerView.backgroundColor = UIColor(named: "767680")
            
            cellIconImage.image = data.icon
            settingsTitle.text = data.name
        }
    }
    @objc func handleChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        default: break
        }
        AppData.selectedGpsAccuracy = sender.selectedSegmentIndex
    }
    private func initializationView() {
        addSubview(conteinerView)
        conteinerView.addSubview(settingsTitle)
        conteinerView.addSubview(cellIconImage)
        conteinerView.addSubview(loader)
        loader.color = .black
        contentView.addSubview(selectView)
    }
    private func setupeConstraint() {
        conteinerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
        }
        settingsTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(cellIconImage.snp.right).inset(-5)
            make.right.equalToSuperview().inset(15)
        }
        cellIconImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
            make.width.height.equalTo(32)
        }
        loader.snp.makeConstraints { make in
            make.center.equalTo(cellIconImage)
        }
        selectView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(46)
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }
}
