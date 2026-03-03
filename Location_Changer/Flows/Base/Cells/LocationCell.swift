
import UIKit
import SnapKit

final class LocationCell: UICollectionViewCell {
    
    private var coordinate: String = ""
    
    private var conteinerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = UIColor(named: "767680")
        return view
    }()
    private var adressTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.numberOfLines = 0
        return view
    }()
    private var coordinateTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "9DA0AE")
        view.font = .systemFont(ofSize: 15, weight: .regular)
        view.numberOfLines = 0
        return view
    }()
    private lazy var copyButton: UIButton = {
        let view = UIButton()
        view.setBackgroundImage(UIImage(named: "copy_icon"), for: .normal)
        view.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return view
    }()
    private var previewImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    lazy var editButton: UIButton = {
        let view = UIButton()
        view.setBackgroundImage(UIImage(named: "edit_icon"), for: .normal)
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
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImage.image = nil
    }
    func configureCell(_ data: LocationSaveData) {
        coordinate = data.coordinate ?? ""
        adressTitle.text = String(format: "%@ %@ %@",
                                  data.country ?? "",
                                  data.city ?? "",
                                  data.street ?? "")
        let fullText = "\(String(localized: "Coordinates:")) \(data.coordinate ?? "")"
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
        previewImage.image = UIImage(data: data.preview ?? Data())
    }
}
private extension LocationCell {
    func initializationView() {
        contentView.addSubview(conteinerView)
        conteinerView.addSubview(adressTitle)
        conteinerView.addSubview(coordinateTitle)
        conteinerView.addSubview(copyButton)
        
        conteinerView.addSubview(previewImage)
        
        conteinerView.addSubview(editButton)
    }
    func setupeConstraint() {
        conteinerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        adressTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.left.equalTo(15)
            make.right.equalTo(editButton.snp.left).inset(-10)
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
        previewImage.snp.makeConstraints { make in
            make.top.equalTo(coordinateTitle.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview().inset(15)
        }
        editButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.top.right.equalToSuperview().inset(15)
        }
    }
    @objc func handleTap(_ sender: UIButton) {
        UIPasteboard.general.string = coordinate
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        showCopyFeedback()
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
        contentView.addSubview(feedbackLabel)
        feedbackLabel.snp.makeConstraints { make in
            make.center.equalTo(coordinateTitle)
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
}
