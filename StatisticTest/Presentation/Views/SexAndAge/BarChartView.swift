import UIKit
import Foundation

class BarChartView: UIView {
    private let progressBar = UIView()
    private let percentageLabel = UILabel()
    private var percentage: CGFloat

    init(color: UIColor?, percentage: CGFloat?) {
        self.percentage = percentage ?? 0
        super.init(frame: .zero)
        setupUI(color: color, percentage: percentage)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePercents(_ percentage: CGFloat) {
        self.percentage = percentage
        percentageLabel.text = "\(Int(percentage))%"
    }

    private func setupUI(color: UIColor?, percentage: CGFloat?) {
        backgroundColor = .clear

        progressBar.backgroundColor = color
        progressBar.layer.cornerRadius = 3
        progressBar.clipsToBounds = true
        addSubview(progressBar)

        percentageLabel.text = "\(Int(percentage ?? 0))%"
        percentageLabel.font = UIFont.systemFont(ofSize: 10)
        percentageLabel.textColor = .black
        addSubview(percentageLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let barHeight: CGFloat = 5
        let barWidth = percentage == 0 ? 5 : bounds.width * (percentage / 100) + 5
        progressBar.frame = CGRect(x: 0, y: (bounds.height - barHeight)/2, width: barWidth, height: barHeight)
        percentageLabel.sizeToFit()
        percentageLabel.frame.origin = CGPoint(x: progressBar.frame.maxX + 8, y: (bounds.height - percentageLabel.frame.height)/2)
    }
}

