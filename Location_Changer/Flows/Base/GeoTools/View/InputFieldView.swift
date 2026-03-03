import UIKit
import SnapKit

class InputFieldView: UIView {
    
    enum ViewMode {
        case coordinate, date, time, device_model
    }
    var didSetText: ((String?) -> Void)?
    var exifData: EXIFData?
    var setMode: ViewMode = .coordinate {
        didSet {
            configureForMode()
        }
    }
    var currentDate = Date()
    
    lazy var textField: UITextField = {
        let view = UITextField()
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.textColor = UIColor(named: "9DA0AE")
//        view.delegate = self
        return view
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(named: "FFFFFF_24")
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private func configureForMode() {
        switch setMode {
        case .coordinate:
            if exifData?.hideCoordinate == true {
                textField.isUserInteractionEnabled = false
                textField.text = "********"
            } else {
                textField.isUserInteractionEnabled = true
                textField.keyboardType = .numbersAndPunctuation
                textField.addTarget(self, action: #selector(coordinateEditingChanged), for: .editingChanged)
            }
        case .date:
            if exifData?.hideDate == true {
                textField.isUserInteractionEnabled = false
                textField.text = "****"
            } else {
                textField.isUserInteractionEnabled = true
                textField.keyboardType = .numberPad
                textField.addTarget(self, action: #selector(dateEditingChanged), for: .editingChanged)
                textField.text = dateFormatter.string(from: currentDate)
            }
        case .time:
            if exifData?.hideDate == true {
                textField.isUserInteractionEnabled = false
                textField.text = "****"
            } else {
                textField.isUserInteractionEnabled = true
                textField.keyboardType = .numberPad
                textField.addTarget(self, action: #selector(timeEditingChanged), for: .editingChanged)
                textField.text = timeFormatter.string(from: currentDate)
            }
        case .device_model:
            if exifData?.hideModel == true {
                textField.isUserInteractionEnabled = false
                textField.text = "*********"
            } else {
                textField.isUserInteractionEnabled = true
//                textField.text = UIDevice.current.name
                textField.keyboardType = .default
                textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
            }
        }
    }
    @objc private func coordinateEditingChanged() {
        if let text = textField.text {
            didSetText?(textField.text)
            let filtered = text.filter { "0123456789.-".contains($0) }
            if filtered != text {
                textField.text = filtered
            }
        }
    }
    @objc private func dateEditingChanged() {
        if let text = textField.text {
            didSetText?(textField.text)
            let numbers = text.filter { "0123456789".contains($0) }
            var formatted = ""
            for (index, char) in numbers.enumerated() {
                if index == 2 || index == 4 {
                    formatted.append(".")
                }
                formatted.append(char)
            }
            if formatted.count > 10 {
                formatted = String(formatted.prefix(10))
            }
            if formatted != text {
                textField.text = formatted
            }
        }
    }
    @objc private func timeEditingChanged() {
        if let text = textField.text {
            didSetText?(textField.text)
            let numbers = text.filter { "0123456789".contains($0) }
            var formatted = ""
            for (index, char) in numbers.enumerated() {
                if index == 2 {
                    formatted.append(":")
                }
                formatted.append(char)
            }
            if formatted.count > 5 {
                formatted = String(formatted.prefix(5))
            }
            if formatted != text {
                textField.text = formatted
            }
        }
    }
    @objc private func textChanged(_ textField: UITextField) {
        didSetText?(textField.text)
    }
}
