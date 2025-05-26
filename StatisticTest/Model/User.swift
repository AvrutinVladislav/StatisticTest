import Foundation
import RealmSwift

//http://test.rikmasters.ru/api/users/

struct UsersResponse: Codable {
    var users: [User]
}

class UserResponseDBObject: Object {
    @Persisted var users: List<UserDBObject>
    
    convenience init(from response: UsersResponse) {
        self.init()
        self.users.append(objectsIn: response.users.map{ UserDBObject(from: $0)})
    }
}

struct User: Codable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
        && lhs.sex == rhs.sex
        && lhs.username == rhs.username
        && lhs.isOnline == rhs.isOnline
        && lhs.age == rhs.age
        && lhs.files == rhs.files
    }
    
    var id: Int
    var sex: Sex
    var username: String
    var isOnline: Bool
    var age: Int
    var files: [File]
    
    enum CodingKeys: String, CodingKey {
        case id
        case sex
        case username
        case isOnline = "isOnline"
        case age
        case files
    }
}

class UserDBObject: Object  {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var sex: Sex
    @Persisted var username: String
    @Persisted var isOnline: Bool
    @Persisted var age: Int
    @Persisted var files: List<FileDBObject>
    
    convenience init(from user: User) {
        self.init()
        self.id = user.id
        self.sex = user.sex
        self.username = user.username
        self.isOnline = user.isOnline
        self.age = user.age
        self.files.append(objectsIn: user.files.map { FileDBObject(from: $0) })
    }
    
    func getUser() -> User {
        return User(id: id,
                    sex: sex,
                    username: username,
                    isOnline: isOnline,
                    age: age,
                    files: files.map { $0.getFile() })
    }
}

enum Sex: String, Codable, PersistableEnum {
    case male = "M"
    case female = "W"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "M": self = .male
        case "W": self = .female
        default: self = .male
        }
    }
}

struct File: Codable, Equatable {
    var id: Int
    var url: String
    var type: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case type
    }
}

class FileDBObject: Object  {
    @Persisted var id: Int
    @Persisted var url: String
    @Persisted var type: String
    
    convenience init(from file: File) {
        self.init()
        self.id = file.id
        self.url = file.url
        self.type = file.type
    }
    
    func getFile() -> File {
        return File(id: id,
                    url: url,
                    type: type)
    }
}

