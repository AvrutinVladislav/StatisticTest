import UIKit
import RxSwift
import RxCocoa

class StatisticViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private let users = BehaviorRelay<[User]>(value: [])
    private let visitorsStatistic = BehaviorRelay<[VisitorsStatistic]>(value: [])
    private let mainVisitors = BehaviorRelay<[MainVisitor]>(value: [])
    private var statistic = BehaviorRelay<[UserStatistic]>(value: [])
    private let ageGenderStatistic = BehaviorSubject<[AgeGroupStats]>(value: [])
    private let genderCount = BehaviorSubject<GenderCounter>(value: GenderCounter())
    private let totalFemales = BehaviorSubject<Int>(value: 0)
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
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension StatisticViewController {
    override func setupUI() {
        statisticView.bindData(users: users.asObservable(),
                               sexAgeData: ageGenderStatistic,
                               genderCount: genderCount,
                               visitorStatistic: visitorsStatistic,
                               mainVisitors: mainVisitors)
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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.sizeToFit()
        
        let titleItem = UIBarButtonItem(customView: titleLabel)
        
        self.navigationItem.title = ""
        
        self.navigationItem.leftBarButtonItems = [titleItem]
    }
    
    func loadData() {
        isLoading.accept(true)
        fetchUsers()
        fetchStatistic()
//        networkProvider.fetchStatistics()
//            .observe(on: MainScheduler.instance)
//            .subscribe(
//                onNext: { [weak self] statistic in
//                    guard let self else { return }
//                    self.statistic.accept(statistic.statistics)
//                    let mainVisitors = self.prepareMainVisitersData()
//                    self.mainVisitors.accept(mainVisitors)
//                    let data = self.processVisitorsData(statistic)
//                    self.visitorsStatistic.accept(data)
//                    self.isLoading.accept(false)
//                },
//                onError: { [weak self] error in
//                    self?.error.onNext(error)
//                    self?.isLoading.accept(false)
//                }
//            )
//            .disposed(by: disposeBag)
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
//        let allViewDates = response.statistics
//            .filter { $0.type.rawValue == "view" }
//            .flatMap { $0.dates }
//        
//        let dates = allViewDates.compactMap { parseDate(from: $0) }
//        
//        var dateCounts = [Date: Int]()
//        for date in dates {
//            dateCounts[date] = (dateCounts[date] ?? 0) + 1
//        }
//        return dateCounts
//            .sorted { $0.key < $1.key}
//            .map {VisitorsStatistic(date: $0.key, visitorsCount: $0.value)}
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
            print("===== \(localUsers.count) users download from Realm")
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
                } else {
                    if self.repository.hasChanges(localUsers: localUsers, remoteUsers: remoteUsers) {
                        self.updateUserData(with: localUsers)
                    } else {
                        self.updateUserData(with: remoteUsers)
                        do {
                            try self.repository.updateUsers(remoteUsers)
                        } catch {
                            print("==== Error to update users in Realm: \(error)")
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
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
            print("===== \(localStatistic.count) statistics download from Realm")
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
                } else {
                    if self.repository.hasChangesStatistic(localStatistics: localStatistic, remoteStatistics: remoteStatistic) {
                        self.updateStatisticData(with: localStatistic)
                    } else {
                        self.updateStatisticData(with: remoteStatistic)
                        do {
                            try repository.updateStatistic(remoteStatistic)
                        } catch {
                            print("==== Error to update statistic to Realm: \(error.localizedDescription)")
                        }
                    }
                }
                
            }
            .disposed(by: disposeBag)
    }
    
    func updateStatisticData(with statistic: [UserStatistic]) {
        self.statistic.accept(statistic)
        let mainVisitors = self.prepareMainVisitersData(with: statistic)
        self.mainVisitors.accept(mainVisitors)
        let data = self.processVisitorsData(statistic)
        self.visitorsStatistic.accept(data)
        self.isLoading.accept(false)
    }
    
    func prepareMainVisitersData(with statistic: [UserStatistic]) -> [MainVisitor] {
        var mainVisitors = [MainVisitor]()
        statistic.forEach { statistic in
            if statistic.type == .view {
                users.value.forEach { user in
                    if user.id == statistic.userId {
                        mainVisitors.append(MainVisitor(name: user.username,
                                                        visitsCount: statistic.dates.count,
                                                        avatarImg: user.files.first?.url))
                    }
                }
            }
        }
        
        return mainVisitors.sorted { $0.visitsCount > $1.visitsCount }
    }
        
}

