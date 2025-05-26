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

struct UserStatistic: Codable {
    var userId: Int
    var type: StatisticType
    var dates: [Int]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case type
        case dates
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
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var userId: Int
    @Persisted var type: StatisticType
    @Persisted var dates: List<Int>
    
    convenience init(from statistic: UserStatistic) {
        self.init()
        self.userId = statistic.userId
        self.type = statistic.type
        self.dates.append(objectsIn: statistic.dates)
    }
    
    func getStatistics() -> UserStatistic {
        return UserStatistic(
            userId: userId,
            type: type,
            dates: Array(dates)
        )
    }
    
}
