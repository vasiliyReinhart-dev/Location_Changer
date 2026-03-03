import UIKit
import SnapKit
import MapKit
import CoreLocation
import Combine

final class CoordinatesCell: UICollectionViewCell {
    
    static let id = "coordinatesCell"
    @Published private(set) var action: EXIFAction = .none
    var cancellables = Set<AnyCancellable>()
    
    private var latitude: Double?
    private var longitude: Double?
    
    private let latitudeInputField = InputFieldView()
    private let longitudeInputField = InputFieldView()
    
    private var headerTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        view.text = String(localized: "Manual setting")
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
    private var latitudeLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.text = String(localized: "Latitude")
        return view
    }()
    private var longitudeLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.text = String(localized: "Longitude")
        return view
    }()
    private lazy var previewMapView: MKMapView = {
       let view = MKMapView()
        view.showsCompass = true
        view.showsScale = true
        view.isUserInteractionEnabled = false
//        view.delegate = self
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    private lazy var pickOnMapButton: UIButton = {
        let view = UIButton()
        view.setTitle(String(localized: "Pick on map"), for: .normal)
        view.setTitleColor(UIColor(named: "base_violet_color"), for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return view
    }()
    private lazy var pickOnMapIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor(named: "base_violet_color")
        view.image = UIImage(systemName: "map")
        return view
    }()
    private lazy var pickOnArrowIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor(named: "base_violet_color")
        view.image = UIImage(named: "pickOnArrowIcon")
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
        
        latitudeInputField.didSetText = { [weak self] text in
            self?.latitude = self?.convertToDouble(text)
            self?.configureMapForCoordinate()
        }
        longitudeInputField.didSetText = { [weak self] text in
            self?.longitude = self?.convertToDouble(text)
            self?.configureMapForCoordinate()
        }
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func convertToDouble(_ string: String?) -> Double? {
        guard let string else { return nil }
        let cleanedString = string.replacingOccurrences(of: ",", with: ".")
        let trimmedString = cleanedString.trimmingCharacters(in: .whitespaces)
        return Double(trimmedString)
    }
    func convertToString(_ value: Double?) -> String? {
        guard let value else { return nil }
        return String(value)
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
    private func configureMapForCoordinate() {
        let coordinate = "\(latitude ?? 0.0), \(longitude ?? 0.0)"
        let coords = coordinate.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard coords.count == 2 else { return }
        let location = CLLocationCoordinate2D(latitude: coords[0],
                                              longitude: coords[1])
        let region = MKCoordinateRegion(center: location,
                                        latitudinalMeters: 500,
                                        longitudinalMeters: 500)
        previewMapView.setRegion(region, animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        previewMapView.addAnnotation(annotation)
    }
    func configureMap(_ location: CLLocation?) {
        guard let location = location else { return }
        let viewRegion = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: 200,
                                            longitudinalMeters: 200)
        self.previewMapView.setRegion(viewRegion,
                                      animated: true)
    }
    private func setupeSubview() {
        contentView.addSubview(headerTitle)
        contentView.addSubview(conteinerView)
        
        conteinerView.addSubview(latitudeLabel)
        conteinerView.addSubview(latitudeInputField)
        conteinerView.addSubview(longitudeLabel)
        conteinerView.addSubview(longitudeInputField)
        
        conteinerView.addSubview(previewMapView)
        
        conteinerView.addSubview(pickOnMapButton)
        pickOnMapButton.addSubview(pickOnMapIcon)
        pickOnMapButton.addSubview(pickOnArrowIcon)
        
        conteinerView.addSubview(lockIcon)
        conteinerView.addSubview(lockLabel)
        conteinerView.addSubview(hiddenSwitch)
    }
    private func subviewConstraint() {
        headerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(15)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(20)
        }
        conteinerView.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
        latitudeLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(15)
            make.right.equalTo(latitudeInputField.snp.right)
            make.height.equalTo(20)
        }
        latitudeInputField.snp.makeConstraints { make in
            make.top.equalTo(latitudeLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(54)
            make.right.equalTo(conteinerView.snp.centerX).offset(-10)
        }
        longitudeLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(15)
            make.left.equalTo(longitudeInputField.snp.left)
            make.height.equalTo(20)
        }
        longitudeInputField.snp.makeConstraints { make in
            make.top.equalTo(longitudeLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.left.equalTo(conteinerView.snp.centerX).offset(10)
        }
        previewMapView.snp.makeConstraints { make in
            make.top.equalTo(longitudeInputField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(140)
        }
        
        pickOnMapButton.snp.makeConstraints { make in
            make.top.equalTo(previewMapView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(25)
        }
        pickOnMapIcon.snp.makeConstraints { make in
            make.centerY.left.equalToSuperview()
            make.width.height.equalTo(24)
        }
        pickOnMapButton.titleLabel?.snp.makeConstraints { make in
            make.left.equalTo(30)
        }
        pickOnArrowIcon.snp.makeConstraints { make in
            make.centerY.right.equalToSuperview()
            make.width.height.equalTo(24)
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
            make.top.equalTo(pickOnMapButton.snp.bottom).offset(15)
            make.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        action = .open_map
    }
    @objc func valueChanges(_ sender: UISwitch) {
        action = .update_hidden(.coordinates, sender.isOn)
    }
    func configure(_ data: EXIFData) {
        latitude = data.location?.coordinate.latitude
        longitude = data.location?.coordinate.longitude
        
        latitudeInputField.textField.text = convertToString(data.location?.coordinate.latitude)
        longitudeInputField.textField.text = convertToString(data.location?.coordinate.longitude)
        
        configureMap(data.location)
//        hiddenSwitch.isUserInteractionEnabled = data.presets == .Own
        hiddenSwitch.isUserInteractionEnabled = false
        hiddenSwitch.isOn = data.hideCoordinate
        latitudeInputField.exifData = data
        longitudeInputField.exifData = data
        latitudeInputField.setMode = .coordinate
        longitudeInputField.setMode = .coordinate
    }
}
