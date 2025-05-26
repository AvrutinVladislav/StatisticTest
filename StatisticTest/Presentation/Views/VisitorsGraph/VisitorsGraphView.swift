import UIKit
import PinLayout
import DGCharts
import RxSwift
import RxCocoa

final class VisitorsGraphView: UIView {
    
    private let disposeBag = DisposeBag()
    var statistic = BehaviorRelay<[VisitorsStatistic]>(value: [])
    
    private let chartView = LineChartView()
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("===== Error init VisitorsGraphView")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all()
        containerView.pin.all().height(210).width(1000)
        chartView.pin
            .vertically()
            .horizontally(5)
            .height(210)
            .minWidth(1000)
        scrollView.contentSize = containerView.frame.size
    }
}

extension VisitorsGraphView {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        setupChart()
        bindData()
    }
    
    private func setupChart() {
        addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(chartView)
        
        let yAxis = chartView.leftAxis
        yAxis.enabled = true
        yAxis.drawAxisLineEnabled = false
        yAxis.drawLabelsEnabled = false
        yAxis.drawGridLinesEnabled = false
        yAxis.drawZeroLineEnabled = false
        
        chartView.rightAxis.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .gray
        xAxis.gridColor = .lightGray
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1
        xAxis.axisLineDashLengths = [10, 4]
        xAxis.axisLineWidth = 1
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.spaceMin = 0.25
        xAxis.spaceMax = 0.25
        
        chartView.legend.enabled = false
        
        let marker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 150, height: 72))
        marker.chartView = chartView
        chartView.marker = marker
        
        chartView.drawMarkers = true
        chartView.highlightPerTapEnabled = true
        chartView.highlightPerDragEnabled = false
    }
    
    private func setData(data: [VisitorsStatistic]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        
        var entries: [ChartDataEntry] = []
        var labels: [String] = []
        
        for i in 0..<data.count {
            let value = Double(data[i].visitorsCount)
            entries.append(ChartDataEntry(x: Double(i), y: value))
            labels.append(dateFormatter.string(from: data[i].date))
        }
        chartView.moveViewToX(Double(data.count - 1))
        
        let dataSet = LineChartDataSet(entries: entries, label: "")
        dataSet.colors = [.systemRed]
        dataSet.circleColors = [.systemRed]
        dataSet.circleRadius = 6
        dataSet.circleHoleRadius = 3
        dataSet.lineWidth = 3
        dataSet.drawValuesEnabled = false
        
        dataSet.highlightEnabled = true
        dataSet.highlightColor = .systemRed
        dataSet.highlightLineDashLengths = [10, 4]
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawVerticalHighlightIndicatorEnabled = true
        
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        chartView.xAxis.setLabelCount(labels.count, force: false)
        
        guard let maxY = entries.map({ $0.y }).max() else { return }

        let dashedLine = { (y: Double) -> ChartLimitLine in
            let line = ChartLimitLine(limit: y)
            line.lineDashLengths = [10, 4]
            line.lineColor = .lightGray
            line.lineWidth = 1
            return line
        }

        let yAxis = chartView.leftAxis
        yAxis.removeAllLimitLines()
        yAxis.addLimitLine(dashedLine(maxY * 0.5))
        yAxis.addLimitLine(dashedLine(maxY * 0.9))
    }
    
    func bindData() {
        statistic
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] statistic in
                if statistic.count != 0 {
                    self?.setData(data: statistic)
                }
            })
            .disposed(by: disposeBag)
    }
}
