import UIKit
import SnapKit
import Combine
import CoreLocation

final class BeforeAndAfterCell: UICollectionViewCell {
    
    static let id = "beforeAndAfterCell"
    @Published private(set) var action: EXIFAction = .none
    var cancellables = Set<AnyCancellable>()
    private let loader = UIActivityIndicatorView()
    
    private var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "E4E6ED")
        return view
    }()
    private var conteinerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = UIColor(named: "767680")
        return view
    }()
    private var beforeLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "9DA0AE")
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.text = String(localized: "Before")
        return view
    }()
    private var afterLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "34C759")
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.text = String(localized: "After")
        return view
    }()
    private let beforeStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 40
        return view
    }()
    private let afterStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 18
        return view
    }()
    private lazy var randomButton: UIButton = {
        let view = UIButton()
        view.setTitle(String(localized: "Random info"), for: .normal)
        view.setTitleColor(UIColor(named: "base_violet_color"), for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        view.backgroundColor = UIColor(named: "E1DDFB")
        view.layer.cornerRadius = 48/2
        view.tag = 0
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return view
    }()
    private lazy var saveButton: UIButton = {
        let view = UIButton()
        view.setTitle(String(localized: "Save changes"), for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        view.backgroundColor = UIColor(named: "base_violet_color")
        view.layer.cornerRadius = 48/2
        view.tag = 1
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
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
        let targetSize = CGSize(width: layoutAttributes.frame.width,
                                height: 0)
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
    private func setupeSubview() {
        contentView.addSubview(separatorView)
        contentView.addSubview(conteinerView)
        conteinerView.addSubview(beforeLabel)
        conteinerView.addSubview(beforeStack)
        conteinerView.addSubview(afterLabel)
        conteinerView.addSubview(afterStack)
        
        contentView.addSubview(randomButton)
        contentView.addSubview(saveButton)
        saveButton.addSubview(loader)
        loader.color = .white
    }
    private func subviewConstraint() {
        separatorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        conteinerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        beforeLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(15)
            make.right.equalTo(beforeStack.snp.right)
            make.height.equalTo(20)
        }
        beforeStack.snp.makeConstraints { make in
            make.top.equalTo(beforeLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(conteinerView.snp.centerX).offset(-10)
            make.bottom.equalToSuperview().inset(20)
        }
        afterLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(15)
            make.left.equalTo(afterStack.snp.left)
            make.height.equalTo(20)
        }
        afterStack.snp.makeConstraints { make in
            make.top.equalTo(afterLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().inset(15)
            make.left.equalTo(conteinerView.snp.centerX).offset(10)
            make.bottom.lessThanOrEqualToSuperview().inset(20)
        }
        randomButton.snp.makeConstraints { make in
            make.top.equalTo(conteinerView.snp.bottom).offset(150)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(48)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(randomButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(0)
        }
        loader.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        switch sender.tag {
        case 0: action = .random_info
        case 1: action = .save
            loader.startAnimating()
        default: break
        }
    }
    private func formattedLocation(_ location: CLLocation?) -> String {
        guard let location else { return "—" }
        return String(format: "%.4f, %.4f",
                      location.coordinate.latitude,
                      location.coordinate.longitude)
    }
    private func addressString(_ placemark: CLPlacemark?) -> String {
        guard let placemark = placemark else { return "—" }
        let country = placemark.country ?? ""
        let city = placemark.locality ?? ""
        let topRow = [country, city].filter { !$0.isEmpty }.joined(separator: ", ")
        let street = placemark.thoroughfare ?? ""
        let houseNumber = placemark.subThoroughfare ?? ""
        let streetFull = [street, houseNumber].filter { !$0.isEmpty }.joined(separator: " ")
        if topRow.isEmpty && streetFull.isEmpty { return "Unknown location" }
        if topRow.isEmpty { return streetFull }
        if streetFull.isEmpty { return topRow }
        return "\(topRow)\n\(streetFull)"
    }
    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return formatter.string(from: date)
    }
    func configure(before: EXIFData,
                   after: EXIFData) {
        loader.stopAnimating()
        beforeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        afterStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let beforeLocRow = EXIFInfoRow(title: String(localized: "Location"),
                                       value: formattedLocation(before.location))
        let afterLocValue = after.hideCoordinate ? "******" : formattedLocation(after.location)
        let afterLocRow = EXIFInfoRow(title: String(localized: "Location"),
                                      value: afterLocValue,
                                      highlight: before.location != after.location)
        beforeStack.addArrangedSubview(beforeLocRow)
        afterStack.addArrangedSubview(afterLocRow)
        if let beforeLoc = before.location {
            Task {
                if let placemark = try? await LocationManager.shared.reverseGeocode(beforeLoc) {
                    let address = addressString(placemark)
                    await MainActor.run { beforeLocRow.updateValue(address) }
                }
            }
        }
        if !after.hideCoordinate, let afterLoc = after.location {
            Task {
                if let placemark = try? await LocationManager.shared.reverseGeocode(afterLoc) {
                    let address = addressString(placemark)
                    await MainActor.run { afterLocRow.updateValue(address) }
                }
            }
        }
        // DEVICE MODEL
        let afterDeviceTitle = after.hideModel ? "****" : after.deviceModel
        beforeStack.addArrangedSubview(EXIFInfoRow(title: String(localized: "Device model"),
                                                   value: before.deviceModel ?? "—"))
        
        afterStack.addArrangedSubview(EXIFInfoRow(title: String(localized: "Device model"),
                                                  value: afterDeviceTitle ?? "—",
                                                  highlight: before.deviceModel != after.deviceModel))
        // DATE
        let afterDateTitle = after.hideModel ? "****" : formattedDate(after.date)
        beforeStack.addArrangedSubview(EXIFInfoRow(title: String(localized: "Date & Time"),
                                                   value: formattedDate(before.date)))
        afterStack.addArrangedSubview(EXIFInfoRow(title: String(localized: "Date & Time"),
                                                  value: afterDateTitle,
                                                  highlight: before.date != after.date))
    }
}
