
import UIKit
import SnapKit

class GeoToolsController: UIViewController {

    private let viewModel = BaseViewModel.shared
    var didOpenPaywall: (() -> Void)?
    
    private var headerTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 22, weight: .bold)
        view.text = String(localized: "Geo Tools")
        return view
    }()
    private let toolsStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.distribution = .fillEqually
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        toolsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        GeoTools.allCases.enumerated().forEach { index, data in
            let view = SelectToolsView()
            view.setupeData(data)
            view.viewButton.tag = index
            view.viewButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
            toolsStack.addArrangedSubview(view)
        }
    }
}
private extension GeoToolsController {
    func setupUI() {
        view.addSubview(headerTitle)
        view.addSubview(toolsStack)
    }
    func setupConstraints() {
        headerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(25)
        }
        toolsStack.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(headerTitle.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottomMargin.equalToSuperview().inset(15)
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        let seelctTools = GeoTools.allCases[sender.tag]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in guard let self else { return }
            switch seelctTools {
            case .editEXIEF:
                if AppData.premiumAccess == false {
                    didOpenPaywall?()
                    dismiss(animated: true)
                } else {
                    let navVC = UINavigationController(rootViewController: EditorController(seelctTools))
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true)
                }
            }
        }
    }
}
