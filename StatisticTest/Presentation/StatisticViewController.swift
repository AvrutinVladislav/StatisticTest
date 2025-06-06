import UIKit
import RxSwift
import RxCocoa
import NetworkAndBusinessLogic

class StatisticViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private let users = BehaviorRelay<[User]>(value: [])
    private let visitorsStatistic = BehaviorRelay<[VisitorsStatistic]>(value: [])
    private let mainVisitors = BehaviorRelay<[MainVisitor]>(value: [])
    private var statistic = BehaviorRelay<[UserStatistic]>(value: [])
    private let ageGenderStatistic = BehaviorSubject<[AgeGroupStats]>(value: [])
    private let genderCount = BehaviorSubject<GenderCounter>(value: GenderCounter())
    private let visitersCounter = BehaviorRelay<VisitersCounter>(value: VisitersCounter())
    private let isLoading = BehaviorRelay<Bool>(value: false)
    private let error = PublishSubject<Error>()
    
    private let networkProvider: NetworkProviderProtocol
    private let repository: RepositoryProtocol
    
    private let statisticView = StatisticView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        configureNavigationBarTitle()
    }
    
    init(networkManager: NetworkProviderProtocol = NetworkProvider(),
         repository: RepositoryProtocol = Repository(realmProvider: RealmProvider()) ) {
        self.networkProvider = networkManager
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension StatisticViewController {
    override func setupUI() {
        statisticView.bindData(users: users.asObservable(),
                               sexAgeData: ageGenderStatistic,
                               genderCount: genderCount,
                               visitorStatistic: visitorsStatistic,
                               mainVisitors: mainVisitors,
                               visitersCount: visitersCounter)
        statisticView.onRefresh = { [weak self] in
            self?.loadData()
        }
    }
    
    override func addSubviews() {
        view.addSubview(statisticView)
    }
    
    override func addConstraints() {
        statisticView.pin
            .all(view.pin.safeArea)
            
    }
    
    func configureNavigationBarTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "Статистика"
        titleLabel.font = Fonts.bold.font(size: 32)
        titleLabel.sizeToFit()
        
        let titleItem = UIBarButtonItem(customView: titleLabel)
        
        self.navigationItem.title = ""
        
        self.navigationItem.leftBarButtonItems = [titleItem]
    }
    
    func loadData() {
        isLoading.accept(true)
        fetchUsers()
        fetchStatistic()
    }
    
    func groupByAgeAndGender(users: [User]) -> [AgeGroupStats] {
        return Ages.allCases.map { ageGroup in
            let filtredUsers = users.filter {
                ageGroup.range.contains($0.age)
            }
            let males = filtredUsers.filter{ $0.sex == .male}.count
            let females = filtredUsers.filter{ $0.sex == .female}.count
            return AgeGroupStats(ageGroup: ageGroup, maleCount: males, femaleCount: females)
        }
    }
    
    func updateGenderCount(from users: [User]) -> GenderCounter {
        var totalMale = 0
        var totalFemale = 0
        users.forEach { user in
            switch user.sex {
            case .male:
                totalMale += 1
            case .female:
                totalFemale += 1
            }
        }
        
        return GenderCounter(maleCount: totalMale, femaleCount: totalFemale)
    }
    
    func processVisitorsData(_ data: [UserStatistic]) -> [VisitorsStatistic] {
           let allViewDates = data
               .filter { $0.type.rawValue == "view" }
               .flatMap { $0.dates }
           let dates = allViewDates.compactMap { parseDate(from: $0) }
           var dateCounts = [Date: Int]()
           dates.forEach { dateCounts[$0] = (dateCounts[$0] ?? 0) + 1 }
           guard let firstDate = dateCounts.keys.min(),
                 let lastDate = dateCounts.keys.max() else {
               return []
           }
           var currentDate = firstDate
           var allDates = [Date]()
           let calendar = Calendar.current
           while currentDate <= lastDate {
               allDates.append(currentDate)
               guard let newDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
               currentDate = newDate
           }
           let result = allDates.map { date in
               VisitorsStatistic(
                   date: date,
                   visitorsCount: dateCounts[date] ?? 0
               )
           }           
           return result
    }
    
    func parseDate(from number: Int) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let formattedNumber = String(format: "%08d", number)
        return dateFormatter.date(from: formattedNumber)
    }
    
    func fetchUsers() {
        var localUsers: [User] = []
        do {
            localUsers = try self.repository.getLocalUsers()
        } catch {
            print("==== Error get local users: \(error.localizedDescription)")
        }
        self.networkProvider.fetchUsers()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] remoteUsers in
                guard let self else { return }
                if localUsers.isEmpty {
                    self.updateUserData(with: remoteUsers)
                    do {
                        try self.repository.saveUsers(remoteUsers)
                    } catch {
                        print("=== Error to save users to Realm: \(error) ===")
                    }
                }
                else if self.repository.hasChanges(localUsers: localUsers, remoteUsers: remoteUsers) {
                    self.updateUserData(with: remoteUsers)
                }
                else {
                    self.updateUserData(with: localUsers)
                    do {
                        try self.repository.updateUsers(remoteUsers)
                    } catch {
                        print("==== Error to update users in Realm: \(error)")
                    }
                }
            }
            .disposed(by: disposeBag)
        self.statisticView.endRefreshing()
    }
    
    private func updateUserData(with users: [User]) {
        self.users.accept(users)
        let grouped = self.groupByAgeAndGender(users: users)
        self.ageGenderStatistic.onNext(grouped)
        let sexCount = self.updateGenderCount(from: users)
        self.genderCount.onNext(sexCount)
        self.isLoading.accept(false)
    }
    
    func fetchStatistic() {
        var localStatistic = [UserStatistic]()
        do {
            localStatistic = try repository.getLocalStatistic()
        } catch {
            print("==== Error get local statistic: \(error.localizedDescription)")
        }
        networkProvider.fetchStatistics()
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] remoteStatistic in
                guard let self else { return }
                if localStatistic.isEmpty {
                    self.updateStatisticData(with: remoteStatistic)
                    do {
                        try repository.saveStatistic(remoteStatistic)
                    } catch {
                        print("==== Error to save statistic to Realm: \(error.localizedDescription)")
                    }
                }
                else if self.repository.hasChangesStatistic(localStatistics: localStatistic, remoteStatistics: remoteStatistic) {
                    self.updateStatisticData(with: remoteStatistic)
                }
                else {
                    self.updateStatisticData(with: localStatistic)
                    do {
                        try repository.updateStatistic(remoteStatistic)
                    } catch {
                        print("==== Error to update statistic to Realm: \(error.localizedDescription)")
                    }
                }
            }
            .disposed(by: disposeBag)
        self.statisticView.endRefreshing()
    }
    
    func updateStatisticData(with statistic: [UserStatistic]) {
        self.statistic.accept(statistic)
        let data = self.processVisitorsData(statistic)
        self.visitorsStatistic.accept(data)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            let mainVisitors = self.prepareMainVisitersData(with: statistic)
            self.mainVisitors.accept(mainVisitors)
        }
        let counter = prepareVisitersCounter(with: statistic)
        visitersCounter.accept(counter)
        self.isLoading.accept(false)
    }
    
    func prepareMainVisitersData(with statistics: [UserStatistic]) -> [MainVisitor] {
        var mainVisitors = [MainVisitor]()
        statistics.forEach { statistic in
            if statistic.type == .view {
                users.value.forEach { user in
                    if user.id == statistic.userId {
                        if mainVisitors.contains(where: {$0.id == user.id}),
                           let index = mainVisitors.firstIndex(where: {$0.id == user.id}) {
                            mainVisitors[index].visitsCount += statistic.dates.count
                        } else {
                            mainVisitors.append(MainVisitor(id: user.id,
                                                            name: user.username,
                                                            visitsCount: statistic.dates.count,
                                                            avatarImg: user.files.first?.url))
                        }
                    }
                }
            }
        }
        return mainVisitors.sorted { $0.visitsCount > $1.visitsCount }
    }
    
    func prepareVisitersCounter(with statistics: [UserStatistic]) -> VisitersCounter {
        var result = VisitersCounter()
        statistics.forEach { statistic in
            switch statistic.type {
            case .view:
                result.viewers += 1
            case .subscription:
                result.newSubs += 1
            case .unsubscription:
                result.unsubs += 1
            }
        }
        return result
    }
    
}

