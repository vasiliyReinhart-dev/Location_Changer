import UIKit
import SnapKit
import PhotosUI
import Combine
import ImageIO
import CoreLocation

class EditorController: UIViewController {

    private let viewModel = BaseViewModel.shared
    private let emptyView = EmptyPhotoView()
    private var leftButton = UIBarButtonItem()
    private var cancellables = Set<AnyCancellable>()
    private var data: [EXIFSection]? {
        didSet { collectionView.reloadData() }
    }
    private var selectedPresets: Presets = .Own {
        didSet {
            if viewModel.exifData != nil {
                viewModel.exifData?.apply(preset: selectedPresets)
            } else {
                viewModel.exifData = selectedPresets.hidenData
            }
        }
    }
    private var correctLocation: CLLocation?
    private var isKeyboardVisible = false
    
    private var headerTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 22, weight: .bold)
        return view
    }()
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
        view.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.id)
        view.register(PresetsCell.self, forCellWithReuseIdentifier: PresetsCell.id)
        view.register(CoordinatesCell.self, forCellWithReuseIdentifier: CoordinatesCell.id)
        view.register(DateEndTimeCell.self, forCellWithReuseIdentifier: DateEndTimeCell.id)
        view.register(DeviceCell.self, forCellWithReuseIdentifier: DeviceCell.id)
        view.register(BeforeAndAfterCell.self, forCellWithReuseIdentifier: BeforeAndAfterCell.id)
        view.delegate = self
        view.dataSource = self
        return view
   }()
    private lazy var selectButton: UIButton = {
        let view = UIButton()
        view.setTitle(String(localized: "Select photo"), for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        view.backgroundColor = UIColor(named: "base_violet_color")
        view.layer.cornerRadius = 48/2
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return view
    }()
    init(_ tools: GeoTools) {
        super.init(nibName: nil, bundle: nil)
        headerTitle.text = tools.name
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        setupUI()
        setupConstraints()
        leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(closeView))
        navigationItem.leftBarButtonItem = leftButton
        viewModel.$exifData
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.updateChanges()
                }
                .store(in: &cancellables)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        setupKeyboardObservers()
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    func updateChanges() {
        guard !isKeyboardVisible else { return }
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPaths {
            guard indexPath.item != 1 else { continue }
            if let cell = collectionView.cellForItem(at: indexPath) {
                if let item = data?[indexPath.item].items {
                    item.configure(cell: cell,
                                   data: viewModel.exifData,
                                   beforeData: viewModel.beforeData) { [weak self] action in
                        self?.handleAcrion(action)
                    }
                }
            }
        }
    }
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    @objc private func keyboardWillShow(notification: NSNotification) {
        isKeyboardVisible = true
    }
    @objc private func keyboardWillHide() {
        isKeyboardVisible = false
        guard let firstResponder = view.findFirstResponder() else { return }
        if let cell = firstResponder.superview(of: DateEndTimeCell.self) {
            if let finalDate = cell.getFinalDate() {
                self.handleAcrion(.updateDate(finalDate))
            }
        } else if let cell = firstResponder.superview(of: DeviceCell.self) {
            if let finalModel = cell.getFinalModel() {
                self.handleAcrion(.updateModel(finalModel))
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
private extension EditorController {
    func setupUI() {
        view.addSubview(headerTitle)
        view.addSubview(collectionView)
        view.addSubview(emptyView)
        view.addSubview(selectButton)
    }
    func setupConstraints() {
        headerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(65)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(25)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(headerTitle.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(selectButton.snp.top)
        }
        selectButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottomMargin.equalToSuperview().inset(15)
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        viewModel.clickAnimate(selectButton)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.openGalary()
        }
    }
    @objc func closeView() {
        dismiss(animated: true)
    }
    func handleAcrion(_ state: EXIFAction) {
        switch state {
        case .none: break
        case .different_photo: openGalary()
        case .select_presets(let presets):
            selectedPresets = presets
        case .open_map:
            let vc = BaseViewController()
            vc.isSelectMode = true
            vc.EXIFSelectMode = true
            vc.photoLocation = correctLocation
            vc.didSetLocation = { [weak self] placemark in guard let self else { return }
                var currentData = self.viewModel.exifData ?? EXIFData(presets: self.selectedPresets,
                                                                      hideCoordinate: false,
                                                                      hideDate: false,
                                                                      hideModel: false)
                currentData.location = placemark?.location
                currentData.apply(preset: self.selectedPresets)
                self.viewModel.exifData = currentData
            }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        case .random_info:
            print("random_info")
            
            
            
            
        case .save:
            savePhoto()
        case .update_hidden(let item, let hidden):
            var data = viewModel.exifData ?? selectedPresets.hidenData ?? EXIFData(hideCoordinate: false, hideDate: false, hideModel: false)
//            selectedPresets = .Own
//            data.presets = .Own
            switch item {
            case .coordinates:
                data.hideCoordinate = hidden
                if hidden { data.location = nil }
            case .date:
                data.hideDate = hidden
                if hidden { data.date = nil }
            case .device:
                data.hideModel = hidden
                if hidden { data.deviceModel = nil }
            default: break
            }
            viewModel.exifData = data
        case .updateDate(let date):
            var updatedData = viewModel.exifData
            updatedData?.date = date
            viewModel.exifData = updatedData
        case .updateModel(let model):
            var updatedData = viewModel.exifData
            updatedData?.deviceModel = model
            viewModel.exifData = updatedData
        }
    }
    func savePhoto() {
        ImageManager.shared.savePhoto(viewModel.exifData)
        ImageManager.shared.isSaveCompleted = { [weak self] isCompleted in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in guard let self else { return }
                switch isCompleted {
                case true:
                    AlertManager.shared.showSuccesSavePhoto(self) {
                        self.dismiss(animated: true)
                    }
                case false:
                    updateChanges()
                    AlertManager.shared.showErrorSavePhoto(self) {
                        self.savePhoto()
                    }
                }
            }
        }
    }
}
extension EditorController: PHPickerViewControllerDelegate {
    func openGalary() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider else { return }
        Task {
            do {
                let image = try await ImageManager.shared.selectImage(provider)
                let metadata = try await ImageManager.shared.fetchRawMetadata(provider)
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.didPickImage(image, metadata: metadata)
                    self.selectButton.alpha = 0.0
                    self.emptyView.alpha = 0.0
                }
            } catch {
                print("Picker error:", error.localizedDescription)
            }
        }
    }
    func didPickImage(_ image: UIImage?,
                      metadata: RawMetadata) {
        data = viewModel.EXIFSection
        correctLocation = metadata.location
        var currentData = EXIFData(image: image,
                                   presets: selectedPresets,
                                   location: metadata.location, 
                                   hideCoordinate: false,
                                   date: metadata.date,
                                   hideDate: false,
                                   deviceModel: metadata.model,
                                   hideModel: false)
        currentData.apply(preset: selectedPresets)
        viewModel.exifData = currentData
        viewModel.beforeData = currentData
    }
}
extension EditorController: UICollectionViewDelegateFlowLayout,
                            UICollectionViewDelegate,
                            UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        data?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       guard let item = data?[indexPath.item].items else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseID,
                                                      for: indexPath)
        item.configure(cell: cell,
                       data: viewModel.exifData,
                       beforeData: viewModel.beforeData) { [weak self] action in
            self?.handleAcrion(action)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
        let width = collectionView.bounds.width - sectionInset.left - sectionInset.right
        return CGSize(width: width,
                      height: UIView.layoutFittingCompressedSize.height)
    }
}
