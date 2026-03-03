import UIKit
import SnapKit
import MapKit
import CoreLocation

class ShowLocation: UIViewController {
    
    enum ViewState {
        case nornal, edit, select
    }

    private let viewModel = BaseViewModel.shared
    private var coordinate: String = ""
    private var isSaveLocation: Bool = false
    private var placemark: CLPlacemark?
    private var saveData: LocationSaveData?
    var isEdit: Bool = false 
    var didSaveSaveLocation: (() -> Void)?
    var didSetLocation: ((CLPlacemark?) -> Void)?
    var setRoute: ((CLLocation?) -> Void)?
    var EXIFSelectMode: Bool = false
    var didOpenPaywall: (() -> Void)?
    
    private var headerTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 22, weight: .bold)
        view.text = String(localized: "Picked location")
        return view
    }()
    private lazy var previewMapView: MKMapView = {
       let view = MKMapView()
        view.showsCompass = true
        view.showsScale = true
        view.delegate = self
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    private var adressTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.numberOfLines = 0
//        view.adjustsFontSizeToFitWidth = true
//        view.minimumScaleFactor = 0.2
        return view
    }()
    private var coordinateTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "9DA0AE")
        view.font = .systemFont(ofSize: 15, weight: .regular)
        view.numberOfLines = 0
//        view.adjustsFontSizeToFitWidth = true
//        view.minimumScaleFactor = 0.2
        return view
    }()
    private lazy var copyButton: UIButton = {
        let view = UIButton()
        view.setBackgroundImage(UIImage(named: "copy_icon"), for: .normal)
        view.tag = 4
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return view
    }()
    private lazy var setButton: UIButton = {
        let view = UIButton()
        view.setTitle(String(localized: "Set location"), for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        view.backgroundColor = UIColor(named: "base_violet_color")
        view.layer.cornerRadius = 48/2
        view.tag = 0
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return view
    }()
    private let buttonStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 10
        view.alignment = .center
        view.distribution = .fillEqually
        return view
    }()
    init(placemark: CLPlacemark?) {
        super.init(nibName: nil, bundle: nil)
        updatePlacemark(placemark)
        if let placemark = placemark {
            let street = placemark.thoroughfare
            saveData = StorageManager.shared.fetchLocation(street)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in guard let self else { return }
                if saveData != nil {
                    isSaveLocation = true
                    setupeButton()
                }
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        setupeButton()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isEdit == true { return }
        if isSaveLocation {
            guard saveData == nil else { return }
            createMapScreenshot(region: previewMapView.region) { [weak self] image in guard let self else { return }
                StorageManager.shared.saveLocation(placemark: placemark,
                                                   preview: image)
            }
        } else {
            guard let id = saveData?.uuid else { return }
            StorageManager.shared.removeLocationData([id])
        }
    }
    private func configureMap(_ placemark: CLPlacemark?) {
        guard let coordinate = placemark?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 800,
                                        longitudinalMeters: 800)
        previewMapView.setRegion(region, animated: false)
        previewMapView.removeAnnotations(previewMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        previewMapView.addAnnotation(annotation)
    }
}
private extension ShowLocation {
    func setupUI() {
        view.addSubview(headerTitle)
        view.addSubview(previewMapView)
        view.addSubview(adressTitle)
        view.addSubview(coordinateTitle)
        view.addSubview(copyButton)
        view.addSubview(setButton)
        view.addSubview(buttonStack)
    }
    func setupConstraints() {
        headerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(25)
        }
        previewMapView.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        adressTitle.snp.makeConstraints { make in
            make.top.equalTo(previewMapView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.greaterThanOrEqualTo(20)
        }
        coordinateTitle.snp.makeConstraints { make in
            make.top.equalTo(adressTitle.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.lessThanOrEqualToSuperview().inset(50)
            make.width.greaterThanOrEqualTo(20)
            make.height.greaterThanOrEqualTo(16)
        }
        copyButton.snp.makeConstraints { make in
            make.centerY.equalTo(coordinateTitle)
            make.width.height.equalTo(24)
            make.left.equalTo(coordinateTitle.snp.right).inset(-10)
        }
        setButton.snp.makeConstraints { make in
            make.top.equalTo(coordinateTitle.snp.bottom).offset(20)
            make.height.equalTo(48)
            make.right.equalTo(adressTitle.snp.centerX)
            make.left.equalTo(20)
            make.bottom.equalToSuperview().inset(15)
        }
        buttonStack.snp.makeConstraints { make in
            make.centerY.equalTo(setButton)
            make.left.equalTo(setButton.snp.right).inset(-10)
            make.height.equalTo(48)
            make.right.lessThanOrEqualToSuperview().inset(20)
        }
    }
    private func setupeButton() {
        let icon = isSaveLocation ? UIImage(named: "isSave_icon") : UIImage(named: "save_icon")
        buttonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        [UIImage(named: "three_icon"), icon, UIImage(named: "share_icon")].enumerated().forEach { index, icon in
            let view = UIButton()
            view.setBackgroundImage(icon, for: .normal)
             view.tag = index + 1
             view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
             buttonStack.addArrangedSubview(view)
         }
     }
    @objc func handleTap(_ sender: UIButton) {
        viewModel.clickAnimate(sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in guard let self else { return }
            switch sender.tag {
            case 0:
                if AppData.premiumAccess == false {
                    didOpenPaywall?()
                    dismiss(animated: true)
                } else {
                    if EXIFSelectMode == false {
                        switch isEdit {
                        case true:
                            if let coordinate = placemark?.location?.coordinate {
                                let region = MKCoordinateRegion(center: coordinate,
                                                                latitudinalMeters: 200,
                                                                longitudinalMeters: 200)
                                createMapScreenshot(region: region) { [weak self] image in guard let self else { return }
                                    StorageManager.shared.editLocation(uuid: saveData?.uuid,
                                                                       placemark: placemark,
                                                                       preview: image)
                                }
                                didSaveSaveLocation?()
                                dismiss(animated: true)
                            }
                        case false:
                            didSetLocation?(placemark)
                            dismiss(animated: true)
                        }
                    } else {
                        didSetLocation?(placemark)
                    }
                }
            case 1:
                if AppData.premiumAccess == false {
                    didOpenPaywall?()
                    dismiss(animated: true)
                } else {
                    setRoute?(placemark?.location)
                    dismiss(animated: true)
                }
            case 2:
                isSaveLocation.toggle()
                setupeButton()
            case 3:
                shareLocation()
            case 4:
                UIPasteboard.general.string = coordinate
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                showCopyFeedback()
            default: break
            }
        }
    }
    private func showCopyFeedback() {
        let feedbackLabel = UILabel()
        feedbackLabel.text = String(localized: "Copied")
        feedbackLabel.textColor = .white
        feedbackLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = .systemFont(ofSize: 14, weight: .medium)
        feedbackLabel.layer.cornerRadius = 8
        feedbackLabel.clipsToBounds = true
        view.addSubview(feedbackLabel)
        feedbackLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
            make.width.equalTo(120)
            make.height.equalTo(36)
        }
        feedbackLabel.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            feedbackLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 1.0, options: [], animations: {
                feedbackLabel.alpha = 0
            }) { _ in
                feedbackLabel.removeFromSuperview()
            }
        }
    }
    func createMapScreenshot(region: MKCoordinateRegion,
                             completion: @escaping (UIImage?) -> Void) {
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = CGSize(width: 372, height: 225)
        options.scale = UIScreen.main.scale
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil)
                return
            }
            let image = snapshot.image
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: .zero)
            let point = snapshot.point(for: self.previewMapView.centerCoordinate)
            
            if let customIcon = UIImage(named: "place_tag") {
                let iconRect = CGRect(x: point.x - customIcon.size.width / 2,
                                      y: point.y - customIcon.size.height,
                                      width: customIcon.size.width,
                                      height: customIcon.size.height)
                customIcon.draw(in: iconRect)
            }
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            completion(finalImage)
        }
    }
    private func shareLocation() {
        let address = adressTitle.text ?? ""
        let coordsText = "\(String(localized: "Coordinates:")) \(coordinate)"
        let cleanCoordinates = coordinate.replacingOccurrences(of: " ", with: "")
        let mapUrlString = "https://maps.apple.com/?ll=\(cleanCoordinates)&q=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        guard let url = URL(string: mapUrlString) else { return }
        let shareText = "\(address)\n\(coordsText)"
        let itemsToShare: [Any] = [shareText, url]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        if let popover = activityViewController.popoverPresentationController {
            activityViewController.modalPresentationStyle = .popover
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX,
                                        y: self.view.bounds.midY,
                                        width: 0,
                                        height: 0)
            popover.permittedArrowDirections = []
        }
        present(activityViewController, animated: true)
    }
}
extension ShowLocation: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let identifier = "CustomPlaceTag"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        let icon = UIImage(named: "place_tag")
        annotationView?.image = icon
        if let imageSize = icon?.size {
            annotationView?.centerOffset = CGPoint(x: 0, y: -imageSize.height / 2)
        }
        return annotationView
    }
}
extension ShowLocation {
    func setupeMode(_ state: ViewState) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in guard let self else { return }
            switch state {
            case .nornal:
                break
            case .edit:
                if isEdit == false { return }
                previewMapView.removeFromSuperview()
                buttonStack.removeFromSuperview()
                adressTitle.snp.remakeConstraints { make in
                    make.top.equalTo(self.headerTitle.snp.bottom).offset(15)
                    make.leading.trailing.equalToSuperview().inset(15)
                    make.height.greaterThanOrEqualTo(20)
                }
                setButton.setTitle(String(localized: "Save location"), for: .normal)
                setButton.snp.makeConstraints { make in
                    make.top.equalTo(self.coordinateTitle.snp.bottom).offset(20)
                    make.height.equalTo(48)
                    make.leading.trailing.equalToSuperview().inset(25)
                    make.bottom.equalToSuperview().inset(15)
                }
                view.layoutIfNeeded()
            case .select:
                if isEdit == true { return }
                previewMapView.removeFromSuperview()
                adressTitle.snp.remakeConstraints { make in
                    make.top.equalTo(self.headerTitle.snp.bottom).offset(15)
                    make.leading.trailing.equalToSuperview().inset(15)
                    make.height.greaterThanOrEqualTo(20)
                }
                view.layoutIfNeeded()
            }
        }
    }
    func updatePlacemark(_ placemark: CLPlacemark?) {
        self.placemark = placemark
        guard let coordinate = placemark?.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters: 300,
                                            longitudinalMeters: 300)
        previewMapView.setRegion(region, animated: true)
        previewMapView.removeAnnotations(previewMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        previewMapView.addAnnotation(annotation)
        
        self.coordinate = "\(coordinate.latitude), \(coordinate.longitude)"
        if let placemark = placemark {
            let city = placemark.locality
            let country = placemark.country
            let street = placemark.thoroughfare
            adressTitle.text = String(format: "%@ %@ %@",
                                      country ?? "",
                                      city ?? "",
                                      street ?? "")
        }
        let fullText = "\(String(localized: "Coordinates:")) \(coordinate.latitude), \(coordinate.longitude)"
        let attributedString = NSMutableAttributedString(string: fullText)
        if let range = fullText.range(of: ": ") {
            let startIndex = fullText.distance(from: fullText.startIndex,
                                               to: range.upperBound)
            let length = fullText.count - startIndex
            attributedString.addAttribute(.foregroundColor,
                                          value: UIColor.black,
                                          range: NSRange(location: startIndex,
                                                         length: length))
        }
        coordinateTitle.attributedText = attributedString
        if isViewLoaded {
            configureMap(placemark)
        }
    }
}
