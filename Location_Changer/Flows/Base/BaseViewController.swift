import UIKit
import SnapKit
import MapKit
import CoreLocation
import Combine

class BaseViewController: UIViewController {
    
    private let viewModel = BaseViewModel.shared
    private var data: AllNecessaryData?
    private let mapTapGesture = UITapGestureRecognizer()
    private var selectLocationView = SelectLocationView(.no_select)
    private let locationsButton = CustomButton(UIImage(named: "favourites_icon"))
    private let settingsButton = CustomButton(UIImage(named: "settings_icon"))
    private let galaryButton = CustomButton(UIImage(named: "galary_icon"))
    private var gameButton = CustomButton(UIImage(named: "game_icon"))
    private var myLocButton = CustomButton(UIImage(systemName: "dot.scope"))
    
    private let weatherView = WeatherView()
    private var cancellables = Set<AnyCancellable>()
    var photoLocation: CLLocation?
    var EXIFSelectMode: Bool = false
    var isSelectMode: Bool = false {
        didSet { setupeSelectMode() }
    }
    
    private var activeShowLocationController: ShowLocation?
    private var selectPlacemark: CLPlacemark?
    private var isSelectedLocations: Bool = false {
        didSet { updateUserLocationImage() }
    }
    
    private var customUserAnnotation: MKPointAnnotation?
    var didSetLocation: ((CLPlacemark?) -> Void)?
    private var locationManager = CLLocationManager()
    private var isSetRoute: Bool = false
    private var currentRouteOverlay: MKPolyline?
    private var routeDestinationAnnotation: MKPointAnnotation?
    
    private let shadowView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.image = UIImage(named: "shadow_image")
        return view
    }()
    private var editTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 22, weight: .bold)
        view.text = String(localized: "Move the map to \nplace the pin")
        view.numberOfLines = 2
        return view
    }()
    private let centerPinView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "place_tag")
        view.contentMode = .scaleAspectFit
        return view
    }()
    private lazy var mapView: MKMapView = {
       let view = MKMapView()
        view.showsCompass = true
        view.showsScale = true
        view.delegate = self
        view.mapType = .standard
        view.showsUserLocation = true
        return view
    }()
    
    init(data: AllNecessaryData? = nil) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        weatherView.setupeData(data?.weather?.current)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        
        locationsButton.didTap = { [weak self] in guard let self else { return }
            viewModel.clickAnimate(locationsButton)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.openSaveLocation()
            }
        }
        settingsButton.didTap = { [weak self] in guard let self else { return }
            viewModel.clickAnimate(settingsButton)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.navigationController?.pushViewController(SettingsViewController(), animated: true)
            }
        }
        galaryButton.didTap = { [weak self] in guard let self else { return }
            viewModel.clickAnimate(galaryButton)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                let height = GeoTools.allCases.count * 64 + 90
                let controller = GeoToolsController()
                controller.didOpenPaywall = { [weak self] in
                    self?.openPaywall()
                }
                if let sheetController = controller.sheetPresentationController {
                    sheetController.detents = [.custom { context in return CGFloat(height) } ]
                    sheetController.prefersGrabberVisible = true
                }
                self?.present(controller, animated: true)
            }
        }
        myLocButton.didTap = { [weak self] in guard let self else { return }
            viewModel.clickAnimate(settingsButton)
            updateMyLocaiton(to: locationManager.location)
        }
        gameButton.didTap = { [weak self] in guard let self else { return }
            viewModel.clickAnimate(gameButton)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in guard let self else { return }
                if EXIFSelectMode == false {
                    if isSetRoute == false {
                        switch isSelectMode {
                        case true:
                            isSelectMode = false
                            activeShowLocationController?.dismiss(animated: true) { [weak self] in
                                self?.activeShowLocationController = nil
                            }
                        case false:
                            isSelectMode = true
                            openLocation(data?.placemark)
                        }
                    } else {
                        cancelRoute()
                    }
                } else {
                    isSelectMode = false
                    EXIFSelectMode = false
                    dismiss(animated: true)
                }
            }
            if EXIFSelectMode == true {
                dismiss(animated: true)
            }
        }
        weatherView.didTap = { [weak self] in guard let self else { return }
            viewModel.clickAnimate(weatherView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                let controller = DetailWeatherController(data: self?.data)
                if let sheetController = controller.sheetPresentationController {
                    sheetController.detents = [.custom { context in return 365 } ]
                    sheetController.prefersGrabberVisible = true
                }
                self?.present(controller, animated: true)
            }
        }
        selectLocationView.removeLocation = { [weak self] in guard let self else { return }
            isSelectedLocations = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMyLocaiton(to: locationManager.location)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in guard let self else { return }
            weatherView.setupeData(data?.weather?.current)
            weatherView.reloadData(false)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard EXIFSelectMode else { return }
        centerPinView.alpha = 1.0
        Task {
            let targetLocation = photoLocation ?? defaultLocation()
            let placemark = try? await LocationManager.shared.reverseGeocode(targetLocation)
            await MainActor.run {
                self.openLocation(placemark)
            }
        }
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("У вас выключена служба геолокации")
            AlertManager.shared.showLocationDenied(self,
                                                   onSettings: { [weak self] in self?.viewModel.openAppSettings() })
        }
    }
    private func defaultLocation() -> CLLocation {
        return data?.placemark?.location ?? CLLocation(latitude: 0,
                                                       longitude: 0)
    }
    func openLocation(_ placemark: CLPlacemark?,
                      isEdit: Bool = false) {
        let controller = ShowLocation(placemark: placemark)
        controller.EXIFSelectMode = EXIFSelectMode
        
        self.activeShowLocationController = controller
        controller.isEdit = isEdit
        if isEdit == true {
            controller.setupeMode(.edit)
        }
        if isSelectMode == true && isEdit == false {
            controller.setupeMode(.select)
        }
        if isSelectMode, let location = placemark?.location {
            let region = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: 300,
                                            longitudinalMeters: 300)
            mapView.setRegion(region, animated: true)
        }
        controller.didSaveSaveLocation = { [weak self] in
            self?.isSelectMode = false
        }
        controller.didSetLocation = { [weak self] placemark in
            if self?.EXIFSelectMode == false {
                self?.selectPlacemark = placemark
                self?.selectLocationView.setupeState(.select(placemark))
                self?.isSelectMode = false
                self?.isSelectedLocations = true
            } else {
                self?.EXIFSelectMode = false
                self?.didSetLocation?(placemark)
                self?.activeShowLocationController?.dismiss(animated: true) { [weak self] in
                    self?.activeShowLocationController = nil
                    self?.dismiss(animated: true)
                }
            }
        }
        controller.setRoute = { [weak self] location in
            self?.setRoute(location)
        }
        controller.didOpenPaywall = { [weak self] in
            self?.isSelectMode = false
            self?.setupeSelectMode()
            self?.openPaywall()
        }
        if let sheetController = controller.sheetPresentationController {
            let customDetentId = UISheetPresentationController.Detent.Identifier("customHeight")
            let customDetent = UISheetPresentationController.Detent.custom(identifier: customDetentId) { context in
                return 200
            }
            sheetController.detents = isSelectMode ? [customDetent] : [.medium()]
            sheetController.largestUndimmedDetentIdentifier = isSelectMode ? customDetentId : nil
            sheetController.prefersGrabberVisible = true
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(controller, animated: true)
    }
    func openSaveLocation() {
        let controller = SaveLocationController()
        controller.didSelectLocation = { [weak self] data, isEdit in guard let self else { return }
            isSelectMode = isEdit
            let location = CLLocation(latitude: data?.latitude ?? 0.0,
                                      longitude: data?.longitude ?? 0.0)
            Task {
                let placemark = await LocationManager.shared.makePlaceMark(location)
                DispatchQueue.main.async {
                    self.openLocation(placemark,
                                      isEdit: isEdit)
                }
            }
        }
        if StorageManager.shared.getAllLocation().isEmpty {
            if let sheetController = controller.sheetPresentationController {
                sheetController.detents = [.medium()]
                sheetController.prefersGrabberVisible = true
            }
        }
        present(controller, animated: true)
    }
    private func openPaywall() {
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(PaywallViewController(), animated: false)
    }
}
private extension BaseViewController {
    func setupUI() {
        view.addSubview(mapView)
        mapTapGesture.addTarget(self, action: #selector(handleMapTap))
        mapView.addGestureRecognizer(mapTapGesture)
        
        view.addSubview(selectLocationView)
        view.addSubview(locationsButton)
        view.addSubview(settingsButton)
        view.addSubview(galaryButton)
        view.addSubview(gameButton)
        view.addSubview(weatherView)
        
        view.addSubview(myLocButton)
        myLocButton.alpha = 0.0
        
        view.addSubview(shadowView)
        shadowView.alpha = 0.0
        shadowView.addSubview(editTitle)
        
        view.addSubview(centerPinView)
        centerPinView.alpha = 0.0
    }
    func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        locationsButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(55)
            make.left.equalTo(15)
            make.width.height.equalTo(48)
        }
        settingsButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(55)
            make.right.equalToSuperview().inset(15)
            make.width.height.equalTo(48)
        }
        selectLocationView.snp.makeConstraints { make in
            make.top.equalTo(locationsButton.snp.top)
            make.left.equalTo(locationsButton.snp.right).inset(-15)
            make.right.equalTo(settingsButton.snp.left).inset(-15)
        }
        galaryButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.width.height.equalTo(48)
            make.bottom.equalTo(view.snp.centerY).offset(-10)
        }
        gameButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.width.height.equalTo(48)
            make.top.equalTo(view.snp.centerY)
        }
        weatherView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(48)
            make.height.equalTo(65)
            make.centerY.equalToSuperview()
        }
        myLocButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.width.height.equalTo(48)
            make.bottomMargin.equalToSuperview().inset(20)
        }
        shadowView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        editTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.greaterThanOrEqualTo(20)
            make.top.equalToSuperview().inset(60)
        }
        centerPinView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            let imageHeight = UIImage(named: "place_tag")?.size.height ?? 0
            make.centerY.equalToSuperview().offset(-imageHeight / 2)
            make.width.height.equalTo(50)
        }
    }
}
extension BaseViewController: CLLocationManagerDelegate,
                              MKMapViewDelegate {
    private func updateUserLocationImage() {
        UIView.animate(withDuration: 0.3) {
            self.weatherView.alpha = self.isSelectedLocations ? 0.0 : 1.0
            self.galaryButton.alpha = self.isSelectedLocations ? 0.0 : 1.0
        }
        if isSelectedLocations {
            mapView.showsUserLocation = false
            if let oldAnnotation = customUserAnnotation {
                mapView.removeAnnotation(oldAnnotation)
            }
            if let coordinate = selectPlacemark?.location?.coordinate {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                customUserAnnotation = annotation
                mapView.addAnnotation(annotation)
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(region, animated: true)
            }
        } else {
            if let oldAnnotation = customUserAnnotation {
                mapView.removeAnnotation(oldAnnotation)
                customUserAnnotation = nil
            }
            mapView.showsUserLocation = true
            if let userLocation = locationManager.location {
                updateMyLocaiton(to: userLocation)
            }
        }
    }
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let resID = "userLocationStyle"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: resID) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: resID)
            view.image = UIImage(named: "location_tag")
            return view
        }
        if let customAnn = annotation as? MKPointAnnotation, customAnn === customUserAnnotation {
            let resID = "customUserStyle"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: resID) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: resID)
            view.image = UIImage(named: "location_tag_green")
            return view
        }
        if let routeAnn = annotation as? MKPointAnnotation, routeAnn === routeDestinationAnnotation {
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
                annotationView?.centerOffset = CGPoint(x: 0,
                                                       y: -imageSize.height / 2)
            }
            return annotationView
        }
        return nil
    }
    func updateMyLocaiton(to location: CLLocation?) {
        guard let location = location else { return }
        let viewRegion = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: 200,
                                            longitudinalMeters: 200)
        self.mapView.setRegion(viewRegion,
                               animated: true)
    }
    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: mapView)
        let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: tappedCoordinate.latitude,
                                  longitude: tappedCoordinate.longitude)
        Task {
            let placemark = await LocationManager.shared.makePlaceMark(location)
            DispatchQueue.main.async {
                self.openLocation(placemark)
            }
        }
    }
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated animated: Bool) {
        guard isSelectMode else { return }
        let centerCoordinate = mapView.centerCoordinate
        let location = CLLocation(latitude: centerCoordinate.latitude,
                                  longitude: centerCoordinate.longitude)
        Task {
            let placemark = await LocationManager.shared.makePlaceMark(location)
            DispatchQueue.main.async { [weak self] in
                self?.activeShowLocationController?.updatePlacemark(placemark)
            }
        }
    }
    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor(named: "base_violet_color")
            renderer.lineWidth = 5.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard isSetRoute,
                let userLocation = locations.last,
                let dest = currentRouteOverlay?.coordinate else { return }
        let destinationLoc = CLLocation(latitude: dest.latitude,
                                        longitude: dest.longitude)
        let distance = userLocation.distance(from: destinationLoc)
        if distance < 20 {
            cancelRoute()
        }
    }
}
private extension BaseViewController {
    func updateButtonAlpha(_ bool: Bool) {
        bool ? mapView.removeGestureRecognizer(mapTapGesture) : mapView.addGestureRecognizer(mapTapGesture)
        UIView.animate(withDuration: 0.3) { [weak self] in guard let self else { return }
            selectLocationView.alpha = bool ? 0.0 : 1.0
            locationsButton.alpha = bool ? 0.0 : 1.0
            settingsButton.alpha = bool ? 0.0 : 1.0
            galaryButton.alpha = bool ? 0.0 : 1.0
            gameButton.iconView.image = bool ? UIImage(named: "x_icon") : UIImage(named: "game_icon")
            weatherView.alpha = bool ? 0.0 : 1.0
        }
    }
    func setupeSelectMode() {
        if isSelectMode {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        updateButtonAlpha(isSelectMode)
        UIView.animate(withDuration: 0.3) { [weak self] in guard let self else { return }
            shadowView.alpha = isSelectMode ? 1.0 : 0.0
            centerPinView.alpha = isSelectMode ? 1.0 : 0.0
            mapView.showsUserLocation = isSelectMode ? false : true
        }
        if !isSelectMode {
            mapView.showsUserLocation = !isSelectedLocations
        } else {
            mapView.showsUserLocation = false
        }
    }
    func setRoute(_ location: CLLocation?) {
        guard let destinationCoordinate = location?.coordinate else { return }
        cancelRoute()
        isSetRoute = true
        isSelectMode = false
        centerPinView.alpha = 0.0
        shadowView.alpha = 0.0
        mapView.showsUserLocation = true
        
        updateButtonAlpha(isSetRoute)
        let annotation = MKPointAnnotation()
        annotation.coordinate = destinationCoordinate
        self.routeDestinationAnnotation = annotation
        mapView.addAnnotation(annotation)
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self,
                  let route = response?.routes.first else { return }
            self.currentRouteOverlay = route.polyline
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    func cancelRoute() {
        isSetRoute = false
        updateButtonAlpha(isSetRoute)
        if let overlay = currentRouteOverlay {
            mapView.removeOverlay(overlay)
            currentRouteOverlay = nil
        }
        if let annotation = routeDestinationAnnotation {
            mapView.removeAnnotation(annotation)
            routeDestinationAnnotation = nil
        }
    }
}
