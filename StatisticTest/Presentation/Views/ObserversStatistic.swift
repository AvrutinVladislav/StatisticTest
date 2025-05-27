import UIKit
import RxSwift
import RxCocoa

final class ObserversStatistic: UIView {
    
    private let disposeBag = DisposeBag()
    
    var visitorsCounter = BehaviorRelay<VisitersCounter>(value: VisitersCounter())
    
    private let imageView = UIImageView()
    private let countLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let isIncreased: Bool
    private var image: UIImage
    private var count: Int = 0
    private var observersDescription: String
    private let type: ViewersType
    
    init(_ image: UIImage,
         _ description: ObserversDescription,
         _ isIncreased: Bool,
         _ type: ViewersType) {
        self.image = image
        self.observersDescription = description.rawValue
        self.isIncreased = isIncreased
        self.type = type
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ObserversStatistic {
    
    func setupUI() {
        visitorsCounter
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] counter in
                guard let self else { return }
                switch self.type {
                case .viewer:
                    count = counter.viewers
                case .subs:
                    count = counter.newSubs
                case .unsubs:
                    count = counter.unsubs
                }
                countLabel.attributedText = formatCountWithArrow(count, isIncreased: isIncreased)
            })
            .disposed(by: disposeBag)
        backgroundColor = .white
        layer.cornerRadius = 16
        
        imageView.image = image
        
        layoutIfNeeded()
        
        descriptionLabel.text = observersDescription
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.font = Fonts.medium.font(size: 15)
        descriptionLabel.textColor = UIColor(.black.opacity(0.5))
        
        addSubview(imageView)
        addSubview(countLabel)
        addSubview(descriptionLabel)
        
        imageView.pin
            .vertically(20)
            .start()
            .width(95)
            .height(60)
        
        countLabel.pin
            .after(of: imageView)
            .top(12)
            .marginStart(20)
            .end()
            .size(.init(width: 100, height: 24))
        
        descriptionLabel.pin
            .start(to: imageView.edge.end)
            .marginStart(20)
            .top(to: countLabel.edge.bottom)
            .marginTop(7)
            .end()
            .bottom(12)
            .minHeight(40)
            .minWidth(200)
        
    }
    
    func formatCountWithArrow(_ count: Int, isIncreased: Bool) -> NSAttributedString {
        let arrow = isIncreased ? "↑" : "↓"
        let color = isIncreased ? UIColor.systemGreen : UIColor.systemRed
        let attributedString = NSMutableAttributedString(
            string: "\(count) ",
            attributes: [.font: Fonts.bold.font(size: 20)]
        )
        let arrowString = NSAttributedString(
            string: arrow,
            attributes: [
                .font: Fonts.bold.font(size: 20),
                .foregroundColor: color,
            ]
        )
        attributedString.append(arrowString)
        return attributedString
    }
}

enum ViewersType: CaseIterable {
    case viewer
    case subs
    case unsubs
}
