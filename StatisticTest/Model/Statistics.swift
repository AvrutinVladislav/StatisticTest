import Foundation
import RealmSwift

//http://test.rikmasters.ru/api/statistics/

struct StatisticsResponse: Codable {
    var statistics: [UserStatistic]
}

class StatisticsResponseDBObject: Object {
    @Persisted var statistics: List<UserStatisticDBObject>
    
    convenience init(from response: StatisticsResponse) {
        self.init()
        self.statistics.append(objectsIn: response.statistics.map { UserStatisticDBObject(from: $0) })
    }
}

struct UserStatistic: Codable, Equatable, Hashable {
    var userId: Int
    var type: StatisticType
    var dates: [Int]
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case type
        case dates
    }
    
    init(from decoder: any Decoder) throws {
        let cotainer = try decoder.container(keyedBy: CodingKeys.self)
        type = try cotainer.decode(StatisticType.self, forKey: .type)
        dates = try cotainer.decode([Int].self, forKey: .dates)
        userId = try cotainer.decode(Int.self, forKey: .userId)
        id = "\(userId)_\(type.rawValue)_\(dates.count)"
    }
    
    init(userId: Int, type: StatisticType, dates: [Int], id: String) {
            self.userId = userId
            self.type = type
            self.dates = dates
            self.id = id
        }
    
    static func == (lhs: UserStatistic, rhs: UserStatistic) -> Bool {
        return lhs.userId == rhs.userId &&
                lhs.type == rhs.type &&
                lhs.dates == rhs.dates &&
                lhs.id == rhs.id
    }
}

enum StatisticType: String, Codable, PersistableEnum {
    case view = "view"
    case subscription = "subscription"
    case unsubscription = "unsubscription"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "view": self = .view
        case "subscription": self = .subscription
        case "unsubscription": self = .unsubscription
        default: self = .view
        }
    }
}

class UserStatisticDBObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var userId: Int
    @Persisted var type: StatisticType
    @Persisted var dates: List<Int>
    
    convenience init(from statistic: UserStatistic) {
        self.init()
        self.id = "\(statistic.userId)_\(statistic.type)_\(statistic.dates.count)"
        self.userId = statistic.userId
        self.type = statistic.type
        self.dates.append(objectsIn: statistic.dates)
    }
    
    func getStatistics() -> UserStatistic {
        return UserStatistic(
            userId: userId,
            type: type,
            dates: Array(dates),
            id: id
        )
    }
    
}
