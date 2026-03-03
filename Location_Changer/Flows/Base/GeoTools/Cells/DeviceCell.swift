import UIKit
import SnapKit
import Combine

final class DeviceCell: UICollectionViewCell {
    
    static let id = "seviceCell"
    @Published private(set) var action: EXIFAction = .none
    var cancellables = Set<AnyCancellable>()
    private let deviceInputField = InputFieldView()
    
    private var conteinerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = UIColor(named: "767680")
        return view
    }()
    private var deviceLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.text = String(localized: "Device model")
        return view
    }()
    private lazy var lockIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor(named: "base_violet_color")
        view.image = UIImage(named: "lock_icon")
        return view
    }()
    private var lockLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.text = String(localized: "Hide")
        return view
    }()
    private lazy var hiddenSwitch: UISwitch = {
        let view = UISwitch()
        view.onTintColor = UIColor(named: "34C759")
        view.addTarget(self, action: #selector(valueChanges), for: .valueChanged)
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupeSubview()
        subviewConstraint()
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
    }
    func getFinalModel() -> String? {
        return deviceInputField.textField.text
    }
    private func setupeSubview() {
        contentView.addSubview(conteinerView)
        conteinerView.addSubview(deviceLabel)
        conteinerView.addSubview(deviceInputField)
        
        conteinerView.addSubview(lockIcon)
        conteinerView.addSubview(lockLabel)
        conteinerView.addSubview(hiddenSwitch)
    }
    private func subviewConstraint() {
        conteinerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(5)
        }
        deviceLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(20)
        }
        deviceInputField.snp.makeConstraints { make in
            make.top.equalTo(deviceLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(54)
        }
        lockIcon.snp.makeConstraints { make in
            make.centerY.equalTo(hiddenSwitch)
            make.left.equalTo(15)
            make.width.height.equalTo(32)
        }
        lockLabel.snp.makeConstraints { make in
            make.centerY.equalTo(lockIcon)
            make.left.equalTo(lockIcon.snp.right).inset(-10)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(20)
        }
        hiddenSwitch.snp.makeConstraints { make in
            make.top.equalTo(deviceInputField.snp.bottom).offset(15)
            make.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    @objc func valueChanges(_ sender: UISwitch) {
        action = .update_hidden(.device, sender.isOn)
    }
    func configure(_ data: EXIFData) {
        hiddenSwitch.isUserInteractionEnabled = data.presets == .Own
        hiddenSwitch.isUserInteractionEnabled = false
        hiddenSwitch.isOn = data.hideModel
        deviceInputField.textField.text = data.deviceModel
        deviceInputField.exifData = data
        deviceInputField.setMode = .device_model
    }
}
