import RealmSwift

protocol RealmProviderProtocol: AnyObject {
    func getRealm() throws -> Realm
}

final class RealmProvider: RealmProviderProtocol {
    func getRealm() throws -> Realm {
        try Realm()
    }
}
