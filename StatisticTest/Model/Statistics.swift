import Foundation

//http://test.rikmasters.ru/api/statistics/

struct StatisticsResponse: Codable {
    let statistics: [UserStatistic]
}

struct UserStatistic: Codable {
    let userId: Int
    let type: StatisticType
    let dates: [Date]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case type
        case dates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(Int.self, forKey: .userId)
        type = try container.decode(StatisticType.self, forKey: .type)
        
        let dateInts = try container.decode([Int].self, forKey: .dates)
        dates = dateInts.map { intDate in
            // Конвертация Int в Date (нужно уточнить формат даты)
            // Предполагаем формат DDMMYYYY
            let day = intDate / 1000000
            let month = (intDate / 10000) % 100
            let year = intDate % 10000
            
            var components = DateComponents()
            components.day = day
            components.month = month
            components.year = year
            
            return Calendar.current.date(from: components) ?? Date()
        }
    }
}

enum StatisticType: String, Codable {
    case view = "view"
    case subscription = "subscription"
    case unsubscription = "unsubscription"
}
