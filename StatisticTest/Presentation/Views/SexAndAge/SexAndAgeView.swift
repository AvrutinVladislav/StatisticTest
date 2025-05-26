import UIKit
import PinLayout
import RxSwift
import RxCocoa
import DGCharts

final class SexAndAgeView: UIView {
    
    private let disposeBag = DisposeBag()
    var ageAndGenderStatistic = BehaviorRelay<[AgeGroupStats]>(value: [])
    var genderCountRelay = BehaviorRelay<GenderCounter>(value: GenderCounter())
    
    private var manPersents = 0
    private var womanPersents = 0
    
    private let chartView = PieChartView()
    private let manIcon = UIView()
    private let manLabel = UILabel()
    private let manPersentsLabel = UILabel()
    private let womanIcon = UIView()
    private let womanLabel = UILabel()
    private let womanPersentsLabel = UILabel()
    private lazy var divaiderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.devaider
        view.frame = CGRect(x: 0, y: 0, width: frame.width, height: 1)
        return view
    }()
    private let sexAndAgeTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addSubviews()
        bindData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addConstraints()
    }
    
}

extension SexAndAgeView {
    func setupUI() {
        setupGenderChart(chartView)
        for label in [manLabel, womanLabel] {
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.pin.width(65)
        }
        for label in [manPersentsLabel, womanPersentsLabel] {
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.pin.width(35)
        }
        for view in [manIcon, womanIcon] {
            view.layer.cornerRadius = 5
        }

        manIcon.backgroundColor = Colors.selectedPeriodeButton
        manLabel.text = "Мужчины"
        manPersentsLabel.text = "\(manPersents)%"
        
        womanIcon.backgroundColor = Colors.woman
        womanLabel.text = "Женщины"
        womanPersentsLabel.text = "\(womanPersents)%"
        
        sexAndAgeTableView.register(SexAndAgeTableViewCell.self,
                                    forCellReuseIdentifier: SexAndAgeTableViewCell.identifire)
        sexAndAgeTableView.separatorStyle = .none
        
    }
    
    func addSubviews() {
        addSubview(chartView)
        addSubview(manIcon)
        addSubview(manLabel)
        addSubview(manPersentsLabel)
        addSubview(womanIcon)
        addSubview(womanLabel)
        addSubview(womanPersentsLabel)
        addSubview(divaiderLineView)
        addSubview(sexAndAgeTableView)
    }
    
    func addConstraints() {
        chartView.pin
            .top(30)
            .hCenter()
            .size(CGSize(width: 170, height: 170))
        
        manIcon.pin
            .top(chartView.frame.height + 54)
            .start(30)
            .size(CGSize(width: 10, height: 10))
        
        manLabel.pin
            .after(of: manIcon)
            .marginStart(6)
            .top(chartView.frame.height + 50)
            .height(20)
        
        manPersentsLabel.pin
            .after(of: manLabel)
            .marginStart(6)
            .top(chartView.frame.height + 50)
            .height(20)
        
        womanPersentsLabel.pin
            .end(30)
            .top(chartView.frame.height + 50)
            .height(20)
        
        womanLabel.pin
            .before(of: womanPersentsLabel)
            .marginEnd(6)
            .top(chartView.frame.height + 50)
            .height(20)
            .width(70)
                
        womanIcon.pin
            .top(chartView.frame.height + 54)
            .before(of: womanLabel)
            .marginEnd(6)
            .size(CGSize(width: 10, height: 10))
        
        divaiderLineView.pin
            .below(of: chartView)
            .marginTop(56)
            .horizontally()
        
        sexAndAgeTableView.pin
            .below(of: divaiderLineView)
            .marginTop(20)
            .horizontally()
            .bottom(20)
    }
    
    func setupGenderChart(_ chartView: PieChartView) {
        //На графике отображается статистика по всем юзерам, даже тем, которые не входя в категорию. А в каегории не вошел 1 человек 15 лет. Я сделал так, как не знаю, что именно надо выводить и с какими кретериями
        let entries = [
            PieChartDataEntry(value: Double(womanPersents), label: ""),
            PieChartDataEntry(value: Double(manPersents), label: "")
        ]

        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = [
            Colors.woman,
            Colors.selectedPeriodeButton
        ]
        dataSet.sliceSpace = 5
        dataSet.selectionShift = 0

        let data = PieChartData(dataSet: dataSet)
        data.setDrawValues(false)

        chartView.data = data
        chartView.usePercentValuesEnabled = true
        chartView.drawHoleEnabled = true
        chartView.holeRadiusPercent = 0.9
        chartView.transparentCircleRadiusPercent = 0.0
        chartView.legend.enabled = false
        chartView.rotationEnabled = false
        chartView.highlightPerTapEnabled = false
    }
    
    func bindData() {
        ageAndGenderStatistic
            .observe(on: MainScheduler.instance)
            .bind(to: sexAndAgeTableView.rx.items(cellIdentifier: SexAndAgeTableViewCell.identifire)) { index, user, cell in
                    
                guard let cell = cell as? SexAndAgeTableViewCell else { return }
                cell.configure(ageRange: user.ageGroup,
                               malePercentage: user.maleCount,
                               femalePercentage: user.femaleCount)
            }.disposed(by: disposeBag)
        
       genderCountRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] count in
                guard let self else { return }
                self.manPersents = count.maleCount
                self.womanPersents = count.femaleCount
                self.setupGenderChart(self.chartView)
                self.getGenderProcents(count.maleCount, count.femaleCount)
            })
            .disposed(by: disposeBag)
    }
    
    func getGenderProcents(_ male: Int, _ woman: Int) {
        let fullCount = male + woman
        let manPersents = Double(male) / Double(fullCount) * 100
        let womanPersents = Double(woman) / Double(fullCount) * 100
        manPersentsLabel.text = "\(customRound(manPersents))%"
        womanPersentsLabel.text = "\(customRound(womanPersents))%"
    }
    
    func customRound(_ value: Double) -> Int {
        if value.isNaN {
            return 0
        }
        else {
            let integerPart = floor(value)
            let fractionalPart = value - integerPart
            
            return fractionalPart > 0.5 ? Int(integerPart) + 1 : Int(integerPart)
        }
    }
    
    
}

