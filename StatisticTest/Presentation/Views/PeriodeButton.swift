import UIKit

class PeriodeButton: UIButton {
    
    var isSelectedButton: Bool = false {
        didSet {
            setupStyle(title: self.title)
        }
    }
    var onTap: (() -> Void)?
    
    private var title = ""
    
    init(isSelected: Bool,
         title: String,
         frame: CGRect = .zero) {
        isSelectedButton = isSelected
        self.title = title
        super.init(frame: frame)
        setupStyle(title: self.title)
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("=====Error for init periode button")
    }
    
    private func setupStyle(title: String) {
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.baseBackgroundColor = isSelectedButton ? Colors.selectedPeriodeButton : Colors.mainBackground
        config.cornerStyle = .capsule
        config.baseForegroundColor = isSelectedButton ? .white : .black
        config.background.strokeColor = .black
        config.background.strokeWidth = isSelectedButton ? 0 : 1
        
        var titleAtr = AttributeContainer()
        titleAtr.font = Fonts.semiBold.font(size: 15)
        config.attributedTitle = AttributedString(title, attributes: titleAtr)
        configuration = config
    }
    
    @objc private func buttonTapped() {
        onTap?()
    }
}

