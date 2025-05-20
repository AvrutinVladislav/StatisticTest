import Foundation

//http://test.rikmasters.ru/api/users/

struct UsersResponse: Codable {
    let users: [User]
}

struct User: Codable {
    let id: Int
    let sex: Sex
    let username: String
    let isOnline: Bool
    let age: Int
    let files: [File]
    
    enum CodingKeys: String, CodingKey {
        case id
        case sex
        case username
        case isOnline = "isOnline"
        case age
        case files
    }
}

enum Sex: String, Codable {
    case male = "M"
    case female = "W"
    case other
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "M": self = .male
        case "W": self = .female
        default: self = .other
        }
    }
}

struct File: Codable {
    let id: Int
    let url: String
    let type: FileType
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case type
    }
}

enum FileType: String, Codable {
    case avatar = "avatar"
    case cover
    case other
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = FileType(rawValue: rawValue) ?? .other
    }
}
