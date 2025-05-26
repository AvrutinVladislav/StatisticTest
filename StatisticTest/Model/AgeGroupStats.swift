import Foundation

struct AgeGroupStats {
    let ageGroup: Ages
    let maleCount: Int
    let femaleCount: Int
}

enum Ages: String, CaseIterable {
    case eighteenToTwentyOne = "18-21"
    case twentyTwoToTwentyFive = "22-25"
    case twentySixToThirty = "26-30"
    case thirtyOneToThirtyFive = "31-35"
    case thirtySixToForty = "36-40"
    case fortyOneToFifty = "40-50"
    case fiftyOneAndAbove = ">50"
    
    var range: ClosedRange<Int> {
        switch self {
        case .eighteenToTwentyOne: return 18...21
        case .twentyTwoToTwentyFive: return 22...25
        case .twentySixToThirty: return 26...30
        case .thirtyOneToThirtyFive: return 31...35
        case .thirtySixToForty: return 36...40
        case .fortyOneToFifty: return 41...50
        case .fiftyOneAndAbove: return 51...150
        }
    }
}

