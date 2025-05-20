import UIKit
import RxSwift
import RxCocoa

class StatisticViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private let users = BehaviorRelay<[User]>(value: [])
    private let isLoading = BehaviorRelay<Bool>(value: false)
    private let error = PublishSubject<Error>()
    private let networkManager = NetworkManager.shared
    
    private let topTitleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let visitorsLabel = UILabel()
    private let visitorsInfoContainerView = ObserversStatistic(UIImage(resource: .topVisitorsGraphDemo), 1356, .riseVisitors, true)
//    private let visitorsInfoContainerView = UIView()
//    private let visitorsGraphImageView = UIImageView()
//    private let visitorsCountLabel = UILabel()
//    private let visitorsCountDescriptionLabel = UILabel()
    
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
    private let sexAndAgeDescriptionView = UIView()
    private let sexAndAgeGraphView = UIView()
    private let iconManImageView = UIImageView()
    private let manTatileLabel = UILabel()
    private let iconWomanImageView = UIImageView()
    private let womanTatileLabel = UILabel()
    
    private let sexAndAgeDividerView = UIView()
    
    private let sexAndAgeDescriptionTableView = UITableView()
    
    private let observersTitleLabel = UILabel()
    private let observersView = UIView()
    private let newObserversView = ObserversStatistic(UIImage(resource: .topVisitorsGraphDemo), 1356, .newObservers, true)
    private let signedOffObserversview = ObserversStatistic(UIImage(resource: .lowStatistics), 10, .newObservers, false)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUsers()
        configureNavigationBarTitle()
    }
    
}

extension StatisticViewController {
    override func setupUI() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        
        visitorsLabel.text = "Посетители"
        visitorsLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
//        visitorsInfoContainerView.backgroundColor = .white
//        visitorsInfoContainerView.layer.cornerRadius = 16
        
//        visitorsGraphImageView.image = UIImage(resource: .topVisitorsGraphDemo)
//        
//        visitorsCountLabel.attributedText = formatCountWithArrow(1356, isIncreased: true)
//        
//        visitorsCountDescriptionLabel.text = "Количество посетителей в этом месяце выросло"
//        visitorsCountDescriptionLabel.numberOfLines = 0
//        visitorsCountDescriptionLabel.font = .systemFont(ofSize: 15, weight: .medium)
//        visitorsCountDescriptionLabel.textColor = UIColor(.black.opacity(0.5))
        
        periodStackView.axis = .horizontal
        periodStackView.spacing = 8
        periodStackView.backgroundColor = .clear
        
        for button in [dayPeriodButton, weekPeriodButton, monthPeriodButton, sexAndAgeDayPeriodButton, sexAndAgeWeekPeriodButton, sexAndAgeMonthPeriodButton, sexAndAgeAllPeriodButton] {
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentHuggingPriority(.required, for: .vertical)
        }
        
        mainVisitorsTitleLabel.text = "Чаще всего посещают Ваш профиль"
        mainVisitorsTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        configureTableView()
        
        sexAndAgeTitleLabel.text = "Пол и возраст"
        sexAndAgeTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        sexAndAgeTimePeriodScrollView.showsHorizontalScrollIndicator = false
        sexAndAgeTimePeriodScrollView.showsVerticalScrollIndicator = false
        sexAndAgeTimePeriodScrollView.alwaysBounceHorizontal = true
        
        sexAndAgeDescriptionView.backgroundColor = .white
        sexAndAgeDescriptionView.layer.cornerRadius = 14
        
        observersView.backgroundColor = .white
        observersView.layer.cornerRadius = 14
        
        observersTitleLabel.text = "Наблюдатели"
        observersTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    override func addSubviews() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(visitorsLabel)
        contentView.addSubview(visitorsInfoContainerView)
        contentView.addSubview(periodStackView)
        contentView.addSubview(graphView)
        contentView.addSubview(mainVisitorsTitleLabel)
        contentView.addSubview(mainVisitorsTableView)
        contentView.addSubview(sexAndAgeTitleLabel)
        contentView.addSubview(sexAndAgeTimePeriodScrollView)
        contentView.addSubview(sexAndAgeDescriptionView)
        contentView.addSubview(observersTitleLabel)
        contentView.addSubview(observersView)
        
//        visitorsInfoContainerView.addSubview(visitorsGraphImageView)
//        visitorsInfoContainerView.addSubview(visitorsCountLabel)
//        visitorsInfoContainerView.addSubview(visitorsCountDescriptionLabel)
        
        periodStackView.addArrangedSubview(dayPeriodButton)
        periodStackView.addArrangedSubview(weekPeriodButton)
        periodStackView.addArrangedSubview(monthPeriodButton)
        
        sexAndAgeTimePeriodScrollView.addSubview(sexAndAgeDayPeriodButton)
        sexAndAgeTimePeriodScrollView.addSubview(sexAndAgeWeekPeriodButton)
        sexAndAgeTimePeriodScrollView.addSubview(sexAndAgeMonthPeriodButton)
        sexAndAgeTimePeriodScrollView.addSubview(sexAndAgeAllPeriodButton)
        
        observersView.addSubview(newObserversView)
        observersView.addSubview(signedOffObserversview)
        
    }
    
    override func addConstraints() {
        
        scrollView.pin.all(view.pin.safeArea)
        
        contentView.pin.all().height(1700)
        
        visitorsLabel.pin
            .top(20)
            .start(16)
            .end(16)
            .sizeToFit(.width)
        
        visitorsInfoContainerView.pin
            .below(of: visitorsLabel)
            .marginTop(12)
            .horizontally(16)
            .height(100)
        
        periodStackView.pin
            .below(of: visitorsInfoContainerView)
            .marginTop(28)
            .horizontally(16)
            .height(32)
        
        graphView.pin
            .below(of: periodStackView)
            .marginTop(50)
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
            .height(200)
        
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
        
        sexAndAgeDescriptionView.pin
            .below(of: sexAndAgeTimePeriodScrollView)
            .marginTop(12)
            .horizontally(16)
            .height(530)
        
        observersTitleLabel.pin
            .below(of: sexAndAgeDescriptionView)
            .marginTop(28)
            .horizontally(16)
            .height(21)
        
        observersView.pin
            .below(of: observersTitleLabel)
            .marginTop(12)
            .horizontally(16)
            .bottom(view.pin.safeArea.bottom + 32)
                        
        newObserversView.pin
            .top()
            .horizontally(16)
            .height(100)
        
        signedOffObserversview.pin
            .below(of: newObserversView)
            .marginTop(2)
            .horizontally(16)
            .bottom()
            .height(100)
        
        scrollView.contentSize = contentView.frame.size
    }
    
    func configureNavigationBarTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "Статистика"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.sizeToFit()
        
        let titleItem = UIBarButtonItem(customView: titleLabel)
        
        self.navigationItem.title = ""
        
        self.navigationItem.leftBarButtonItems = [titleItem]
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
    
    func loadUsers() {
        isLoading.accept(true)
        networkManager.fetchUsers()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] users in
                    self?.users.accept(users)
                    self?.isLoading.accept(false)
                },
                onError: { [weak self] error in
                    self?.error.onNext(error)
                    self?.isLoading.accept(false)
                }
            ).disposed(by: disposeBag)
    }
    
    func configureTableView() {
        mainVisitorsTableView.register(MainVisitorsTableViewCell.self, forCellReuseIdentifier: MainVisitorsTableViewCell.identifier)
        mainVisitorsTableView.rowHeight = 62
        mainVisitorsTableView.separatorStyle = .none
        mainVisitorsTableView.layer.cornerRadius = 14
        
        users.bind(to: mainVisitorsTableView.rx.items(cellIdentifier: MainVisitorsTableViewCell.identifier,
                                                      cellType: MainVisitorsTableViewCell.self)) { row, user, cell in
            cell.configureCell(model: user)
        }.disposed(by: disposeBag)
        
        error.subscribe(onNext: { [weak self] error in
            self?.showError(error)
        }).disposed(by: disposeBag)
    }
    
    private func showError(_ error: Error) {
            let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
}

