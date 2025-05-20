import UIKit

final class ObserversStatistic: UIView {
    
    private let imageView = UIImageView()
    private let countLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let isIncreased: Bool
    private var image: UIImage
    private var count: Int
    private var observersDescription: String
    
    init(_ image: UIImage,
         _ count: Int,
         _ description: ObserversDescription,
         _ isIncreased: Bool) {
        self.image = image
        self.count = count
        self.observersDescription = description.rawValue
        self.isIncreased = isIncreased
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ObserversStatistic {
    
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        
        imageView.image = image
        
        countLabel.attributedText = formatCountWithArrow(count, isIncreased: isIncreased)
        
        descriptionLabel.text = observersDescription
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .medium)
        descriptionLabel.textColor = UIColor(.black.opacity(0.5))
        
        addSubview(imageView)
        addSubview(countLabel)
        addSubview(descriptionLabel)
        
        imageView.pin
            .vertically(20)
            .start(16)
            .width(95)
            .height(60)
        
        countLabel.pin
            .after(of: imageView)
            .top(12)
            .marginStart(20)
            .end(16)
            .size(.init(width: 100, height: 24))
        
        descriptionLabel.pin
            .start(to: imageView.edge.end)
            .marginStart(20)
            .top(to: countLabel.edge.bottom)
            .marginTop(7)
            .end(16)
            .bottom(12)
            .minHeight(40)
            .minWidth(200)
        
    }
    
    func formatCountWithArrow(_ count: Int, isIncreased: Bool) -> NSAttributedString {
        let arrow = isIncreased ? "↑" : "↓"
        let color = isIncreased ? UIColor.systemGreen : UIColor.systemRed
        let attributedString = NSMutableAttributedString(
            string: "\(count) ",
            attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        )
        let arrowString = NSAttributedString(
            string: arrow,
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: color,
            ]
        )
        attributedString.append(arrowString)
        return attributedString
    }
}
