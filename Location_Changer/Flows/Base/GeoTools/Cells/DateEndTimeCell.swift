import UIKit
import SnapKit
import Combine

final class DateEndTimeCell: UICollectionViewCell {
    
    static let id = "dateEndTimeCell"
    @Published private(set) var action: EXIFAction = .none
    var cancellables = Set<AnyCancellable>()
    
    private let dateInputField = InputFieldView()
    private let timeInputField = InputFieldView()
    
    private var conteinerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = UIColor(named: "767680")
        return view
    }()
    private var dateLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.text = String(localized: "Date")
        return view
    }()
    private var timeLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = UIColor(named: "0B0C0F")
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.text = String(localized: "Time")
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
    func getFinalDate() -> Date? {
        let calendar = Calendar.current
        let dateStr = dateInputField.textField.text ?? ""
        let timeStr = timeInputField.textField.text ?? ""
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd.MM.yyyy"
        guard let datePart = formatter.date(from: dateStr) else { return nil }
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: datePart)
        formatter.dateFormat = "HH:mm"
        guard let timePart = formatter.date(from: timeStr) else { return nil }
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timePart)
        var finalComponents = DateComponents()
        finalComponents.year = dateComponents.year
        finalComponents.month = dateComponents.month
        finalComponents.day = dateComponents.day
        finalComponents.hour = timeComponents.hour
        finalComponents.minute = timeComponents.minute
        finalComponents.second = 0
        
        return calendar.date(from: finalComponents)
    }
    private func setupeSubview() {
        contentView.addSubview(conteinerView)
        
        conteinerView.addSubview(dateLabel)
        conteinerView.addSubview(dateInputField)
        conteinerView.addSubview(timeLabel)
        conteinerView.addSubview(timeInputField)
        
        conteinerView.addSubview(lockIcon)
        conteinerView.addSubview(lockLabel)
        conteinerView.addSubview(hiddenSwitch)
    }
    private func subviewConstraint() {
        conteinerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(15)
            make.right.equalTo(dateInputField.snp.right)
            make.height.equalTo(20)
        }
        dateInputField.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(54)
            make.right.equalTo(conteinerView.snp.centerX).offset(-10)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(15)
            make.left.equalTo(timeInputField.snp.left)
            make.height.equalTo(20)
        }
        timeInputField.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.left.equalTo(conteinerView.snp.centerX).offset(10)
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
            make.top.equalTo(timeInputField.snp.bottom).offset(15)
            make.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    private func updateAction(_ date: Date) {
        self.action = .updateDate(date)
    }
    @objc func valueChanges(_ sender: UISwitch) {
        action = .update_hidden(.date, sender.isOn)
    }
    func configure(_ data: EXIFData) {
        hiddenSwitch.isUserInteractionEnabled = data.presets == .Own
        hiddenSwitch.isUserInteractionEnabled = false
        hiddenSwitch.isOn = data.hideDate
        
        dateInputField.currentDate = data.date ?? Date()
        timeInputField.currentDate = data.date ?? Date()
        
        dateInputField.exifData = data
        timeInputField.exifData = data
        dateInputField.setMode = .date
        timeInputField.setMode = .time
    }
}
