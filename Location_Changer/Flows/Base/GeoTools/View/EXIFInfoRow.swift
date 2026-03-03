import UIKit
import SnapKit

final class EXIFInfoRow: UIView {
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textColor = UIColor(named: "9DA0AE")
        return view
    }()
    private let valueLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.textColor = UIColor(named: "0B0C0F")
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping // Позволяет корректно переносить слова
        return view
    }()
//    private let valueLabel: UILabel = {
//        let view = UILabel()
//        view.font = .systemFont(ofSize: 17, weight: .semibold)
//        view.textColor = UIColor(named: "0B0C0F")
//        view.numberOfLines = 2
//        return view
//    }()
    init(title: String,
         value: String,
         highlight: Bool = false) {
        super.init(frame: .zero)
        titleLabel.text = title
        valueLabel.text = value
        
        if highlight {
            valueLabel.textColor = UIColor(named: "34C759")
        }
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        stack.distribution = .fill
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    func updateValue(_ newValue: String) {
        self.valueLabel.text = newValue
    }
}
