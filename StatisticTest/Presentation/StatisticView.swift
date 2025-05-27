import UIKit
import RxSwift
import RxCocoa

final class StatisticView: UIView {
    var onRefresh: (() -> Void)?
    private let disposeBag = DisposeBag()
    
    private let refreshControl = UIRefreshControl()
    
    private let topTitleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let visitorsLabel = UILabel()
    private lazy var visitorsInfoView = ObserversStatistic(UIImage(resource: .topVisitorsGraphDemo),
                                                           .riseVisitors, true, .viewer)
    
    private let periodStackView = UIStackView()
    private let dayPeriodButton = PeriodeButton(isSelected: true, title: "По дням")
    private let weekPeriodButton = PeriodeButton(isSelected: false, title: "По неделям")
    private let monthPeriodButton = PeriodeButton(isSelected: false, title: "По месяцам")
    private let graphView = VisitorsGraphView()
    private let mainVisitorsTitleLabel = UILabel()
    private let mainVisitorsTableView = UITableView()
    
    private let sexAndAgeTitleLabel = UILabel()
    private let sexAndAgeTimePeriodScrollView = UIScrollView()
    private let sexAndAgeDayPeriodButton = PeriodeButton(isSelected: true, title: "Сегодня")
    private let sexAndAgeWeekPeriodButton = PeriodeButton(isSelected: false, title: "Неделя")
    private let sexAndAgeMonthPeriodButton = PeriodeButton(isSelected: false, title: "Месяц")
    private let sexAndAgeAllPeriodButton = PeriodeButton(isSelected: false, title: "Все время")
    private let sexAndAgeView = SexAndAgeView()
    
    private let observersTitleLabel = UILabel()
    private let observersView = UIView()
    private lazy var newObserversView = ObserversStatistic(UIImage(resource: .topVisitorsGraphDemo),
                                                      .newObservers, true, .subs)
    private lazy var lessObserversview = ObserversStatistic(UIImage(resource: .lowStatistics),
                                                            .lostObservers, false, .unsubs)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addConstraints()
        mainVisitorsTitleLabel.font = Fonts.bold.font(size: mainVisitorsTitleLabel.frame.width > 359 ? 20 : 18)
    }
    
    func bindData(users: Observable<[User]>,
                  sexAgeData: Observable<[AgeGroupStats]>,
                  genderCount: BehaviorSubject<GenderCounter>,
                  visitorStatistic: BehaviorRelay<[VisitorsStatistic]>,
                  mainVisitors: BehaviorRelay<[MainVisitor]>,
                  visitersCount: BehaviorRelay<VisitersCounter>) {
        mainVisitors
            .observe(on: MainScheduler.instance)
            .bind(to: mainVisitorsTableView.rx.items(cellIdentifier: MainVisitorsTableViewCell.identifier)) { index, mainVisitor, cell in
                    
                guard let cell = cell as? MainVisitorsTableViewCell else { return }
                cell.configureCell(model: mainVisitor)
            }
            .disposed(by: disposeBag)
        
        sexAgeData
            .bind(to: sexAndAgeView.ageAndGenderStatistic)
            .disposed(by: disposeBag)
        
        genderCount
            .bind(to: sexAndAgeView.genderCountRelay)
            .disposed(by: disposeBag)
        
        visitorStatistic
            .bind(to: graphView.statistic)
            .disposed(by: disposeBag)
        
        for view in [visitorsInfoView, newObserversView, lessObserversview] {
            visitersCount
                .bind(to: view.visitorsCounter)
                .disposed(by: disposeBag)
        }
        
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
}

extension StatisticView {
    func setupUI() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        
        visitorsLabel.text = "Посетители"
        visitorsLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        periodStackView.axis = .horizontal
        periodStackView.spacing = 8
        periodStackView.backgroundColor = .clear
        
        for button in [dayPeriodButton, weekPeriodButton, monthPeriodButton, sexAndAgeDayPeriodButton, sexAndAgeWeekPeriodButton, sexAndAgeMonthPeriodButton, sexAndAgeAllPeriodButton] {
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentHuggingPriority(.required, for: .vertical)
        }
        for button in [dayPeriodButton, weekPeriodButton, monthPeriodButton] {
            button.addTarget(self, action: #selector(visitorsButtonDidTap(_:)), for: .touchUpInside)
        }
        for button in [sexAndAgeDayPeriodButton, sexAndAgeWeekPeriodButton, sexAndAgeMonthPeriodButton, sexAndAgeAllPeriodButton] {
            button.addTarget(self, action: #selector(sexAndAgeButtonDidTap(_:)), for: .touchUpInside)
        }
        
        mainVisitorsTitleLabel.text = "Чаще всего посещают Ваш профиль"
        mainVisitorsTitleLabel.font = Fonts.bold.font(size: 20)
        
        mainVisitorsTableView.register(MainVisitorsTableViewCell.self,
                                       forCellReuseIdentifier: MainVisitorsTableViewCell.identifier)
        mainVisitorsTableView.rowHeight = 62
        mainVisitorsTableView.separatorStyle = .none
        mainVisitorsTableView.layer.cornerRadius = 14
        
        sexAndAgeTitleLabel.text = "Пол и возраст"
        sexAndAgeTitleLabel.font = Fonts.bold.font(size: 20)
        
        sexAndAgeTimePeriodScrollView.showsHorizontalScrollIndicator = false
        sexAndAgeTimePeriodScrollView.showsVerticalScrollIndicator = false
        sexAndAgeTimePeriodScrollView.alwaysBounceHorizontal = true
        
        sexAndAgeView.backgroundColor = .white
        sexAndAgeView.layer.cornerRadius = 14
        
        observersView.backgroundColor = .white
        observersView.layer.cornerRadius = 14
        
        observersTitleLabel.text = "Наблюдатели"
        observersTitleLabel.font = Fonts.bold.font(size: 20)
    }
    
    func addSubviews() {
        addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(visitorsLabel)
        contentView.addSubview(visitorsInfoView)
        contentView.addSubview(periodStackView)
        contentView.addSubview(graphView)
        contentView.addSubview(mainVisitorsTitleLabel)
        contentView.addSubview(mainVisitorsTableView)
        contentView.addSubview(sexAndAgeTitleLabel)
        contentView.addSubview(sexAndAgeTimePeriodScrollView)
        contentView.addSubview(sexAndAgeView)
        contentView.addSubview(observersTitleLabel)
        contentView.addSubview(observersView)
        
        periodStackView.addArrangedSubview(dayPeriodButton)
        periodStackView.addArrangedSubview(weekPeriodButton)
        periodStackView.addArrangedSubview(monthPeriodButton)
        
        sexAndAgeTimePeriodScrollView.addSubview(sexAndAgeDayPeriodButton)
        sexAndAgeTimePeriodScrollView.addSubview(sexAndAgeWeekPeriodButton)
        sexAndAgeTimePeriodScrollView.addSubview(sexAndAgeMonthPeriodButton)
        sexAndAgeTimePeriodScrollView.addSubview(sexAndAgeAllPeriodButton)
        
        observersView.addSubview(newObserversView)
        observersView.addSubview(lessObserversview)
    }
    
    func addConstraints() {
        scrollView.pin.all()
        
        contentView.pin.all().height(1700).width(scrollView.frame.width)
        
        visitorsLabel.pin
            .top(20)
            .start(16)
            .end(16)
            .sizeToFit(.width)
        
        visitorsInfoView.pin
            .below(of: visitorsLabel)
            .marginTop(12)
            .horizontally(16)
            .height(100)
        
        periodStackView.pin
            .below(of: visitorsInfoView)
            .marginTop(28)
            .horizontally(16)
            .height(32)
        
        graphView.pin
            .below(of: periodStackView)
            .marginTop(12)
            .horizontally(16)
            .height(210)
        
        mainVisitorsTitleLabel.pin
            .below(of: graphView)
            .marginTop(28)
            .horizontally(16)
            .height(24)
        
        mainVisitorsTableView.pin
            .below(of: mainVisitorsTitleLabel)
            .marginTop(12)
            .horizontally(16)
            .height(190)
        
        sexAndAgeTitleLabel.pin
            .below(of: mainVisitorsTableView)
            .marginTop(28)
            .horizontally(16)
            .height(21)
        
        sexAndAgeTimePeriodScrollView.pin
            .below(of: sexAndAgeTitleLabel)
            .marginTop(12)
            .horizontally(16)
            .height(32)
        sexAndAgeTimePeriodScrollView.contentSize = CGSize(width: 450, height: 32)
        
        sexAndAgeDayPeriodButton.pin.vertically().start().width(100)
        
        sexAndAgeWeekPeriodButton.pin
            .after(of: sexAndAgeDayPeriodButton)
            .marginStart(8)
            .vertically()
            .width(100)
        
        sexAndAgeMonthPeriodButton.pin
            .after(of: sexAndAgeWeekPeriodButton)
            .marginStart(8)
            .vertically()
            .width(100)
        
        sexAndAgeAllPeriodButton.pin
            .after(of: sexAndAgeMonthPeriodButton)
            .marginStart(8)
            .vertically()
            .end()
            .width(110)
        
        sexAndAgeView.pin
            .below(of: sexAndAgeTimePeriodScrollView)
            .marginTop(12)
            .horizontally(16)
            .height(600)
        
        observersTitleLabel.pin
            .below(of: sexAndAgeView)
            .marginTop(28)
            .horizontally(16)
            .height(21)
        
        observersView.pin
            .below(of: observersTitleLabel)
            .marginTop(12)
            .horizontally(16)
            .bottom(pin.safeArea.bottom + 32)
            .height(210)
                        
        newObserversView.pin
            .top()
            .horizontally(16)
            .height(100)
        
        lessObserversview.pin
            .below(of: newObserversView)
            .marginTop(2)
            .horizontally(16)
            .bottom()
            .height(100)
        
        scrollView.contentSize = contentView.frame.size
    }
    
    @objc func visitorsButtonDidTap(_ sender: UIButton) {
        for button in [dayPeriodButton, weekPeriodButton, monthPeriodButton] {
            if button == sender {
                button.isSelectedButton = true
                button.onTap = { [weak self] in
                    
                }
            } else {
                button.isSelectedButton = false
            }
        }
    }
    
    @objc func sexAndAgeButtonDidTap(_ sender: UIButton) {
        for button in [sexAndAgeDayPeriodButton, sexAndAgeWeekPeriodButton, sexAndAgeMonthPeriodButton, sexAndAgeAllPeriodButton] {
            if button == sender {
                button.isSelectedButton = true
                button.onTap = { [weak self] in
                    
                }
            } else {
                button.isSelectedButton = false
            }
        }
    }
    
    @objc func refreshPulled() {
        onRefresh?()
    }
   
}
