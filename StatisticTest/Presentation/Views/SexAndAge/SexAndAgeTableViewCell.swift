import UIKit
import PinLayout

final class SexAndAgeTableViewCell: UITableViewCell {
    
    static let identifire = "SexAndAgeTableViewCell"
    
    private let ageLabel = UILabel()
    private let manBar = BarChartView(color: Colors.selectedPeriodeButton,
                                      percentage: 0)
    private let womanBar = BarChartView(color: Colors.woman,
                                        percentage: 0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addConstraints()
    }
    
    override func prepareForReuse() {
        
    }
    
    func configure(ageRange: Ages,
                   malePercentage: Int,
                   femalePercentage: Int) {
        manBar.updatePercents(CGFloat(malePercentage))
        womanBar.updatePercents(CGFloat(femalePercentage))
        ageLabel.text = ageRange.rawValue
                
    }
}

extension SexAndAgeTableViewCell {
    func setupUI() {
        ageLabel.font = .boldSystemFont(ofSize: 18)

    }
    
    func addSubviews() {
        contentView.addSubview(ageLabel)
        contentView.addSubview(manBar)
        contentView.addSubview(womanBar)
    }
    
    func addConstraints() {
        ageLabel.pin
            .vertically(6)
            .start(24)
            .height(27)
            .width(60)
        
        manBar.pin
            .top(5)
            .after(of: ageLabel)
            .marginStart(30)
            .end()
            .height(11)
            .width(contentView.frame.width - 94)
        
        womanBar.pin
            .below(of: manBar)
            .marginTop(5)
            .after(of: ageLabel)
            .marginStart(30)
            .end()
            .height(11)
            .width(contentView.frame.width - 94)
    }
    
}

