import DGCharts
import UIKit
import PinLayout

class CustomMarkerView: MarkerView {
    
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.layer.borderColor = Colors.tabbarBorder.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = Colors.selectedPeriodeButton
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .black.withAlphaComponent(0.5)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(container)
        container.addSubview(label)
        container.addSubview(dateLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if let formatter = self.chartView?.xAxis.valueFormatter as? IndexAxisValueFormatter {
            let index = Int(entry.x)
            if index < formatter.values.count {
                dateLabel.text = convertDate(formatter.values[index])
            }
        }
        label.text = "\(Int(entry.y)) посетителей"
        label.font = Fonts.semiBold.font(size: 15)
        dateLabel.font = Fonts.medium.font(size: 13)
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        label.frame = CGRect(x: 16, y: 16, width: frame.width - 32, height: 18)
        dateLabel.frame = CGRect(x: 16, y: 40, width: frame.width - 32, height: 16)
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let markerSize = bounds.size
        let markerWidth = markerSize.width
        let markerHeight = markerSize.height
        
        let screenBounds = UIScreen.main.bounds
        let screenWidth = screenBounds.width
        
        let yAbove = point.y - markerHeight - 8
        let yOffset = (yAbove > 0) ? -markerHeight - 8 : 8
        
        var xOffset: CGFloat = -markerWidth / 2
        
        let leftEdge = point.x + xOffset
        if leftEdge < 16 {
            xOffset = -(point.x - 16)
        }
        
        let rightEdge = point.x + xOffset + markerWidth
        if rightEdge > screenWidth - 60 {
            xOffset = screenWidth - 60 - point.x - markerWidth
        }
        
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    private func convertDate(_ date: String) -> String {
        let format = DateFormatter()
        format.dateFormat = "dd.MM"
        var result = ""
        if let dateFromString = format.date(from: date) {
            format.dateFormat = "d MMMM"
            format.locale = Locale(identifier: "ru_RU")
            result = format.string(from: dateFromString)
        }
        return result
    }
}
