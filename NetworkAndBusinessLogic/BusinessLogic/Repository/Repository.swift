import RealmSwift

final public class Repository: RepositoryProtocol {
    
    private let realmProvider: RealmProviderProtocol
    
    init(realmProvider: RealmProviderProtocol) {
        self.realmProvider = realmProvider
    }
    
    func getLocalUsers() throws -> [User] {
        let realm = try realmProvider.getRealm()
        return realm.objects(UserDBObject.self).map{ $0.getUser() }
    }
    
    func getLocalStatistic() throws -> [UserStatistic] {
        let realm = try realmProvider.getRealm()
        return realm.objects(UserStatisticDBObject.self).map { $0.getStatistics() }
    }
    
    func saveUsers(_ users: [User]) throws {
        let realm = try realmProvider.getRealm()
        try realm.write {
            realm.add(users.map { UserDBObject(from: $0) }, update: .modified)
        }
    }
    
    func saveStatistic(_ users: [UserStatistic]) throws {
        let realm = try realmProvider.getRealm()
        try realm.write {
            realm.add(users.map { UserStatisticDBObject(from: $0) }, update: .modified)
        }
    }
    
    func updateUsers(_ users: [User]) throws {
        let realm = try realmProvider.getRealm()
        try realm.write {
            users.forEach { user in
                if let existigUser = realm.object(ofType: UserDBObject.self, forPrimaryKey: user.id) {
                    existigUser.username = user.username
                    existigUser.age = user.age
                    existigUser.isOnline = user.isOnline
                    existigUser.sex = user.sex
                    
                    existigUser.files.removeAll()
                    existigUser.files.append(objectsIn: user.files.map{ FileDBObject(from: $0) })
                }
            }
        }
    }
    
    func updateStatistic(_ statistics: [UserStatistic]) throws {
        let realm = try realmProvider.getRealm()
        try realm.write {
            statistics.forEach { statistic in
                if let existigStatistic = realm.object(ofType: UserStatisticDBObject.self, forPrimaryKey: statistic.id) {
                    existigStatistic.type = statistic.type
                    existigStatistic.dates.removeAll()
                    existigStatistic.dates.append(objectsIn: statistic.dates)
                }
            }
        }
    }
    
    func hasChanges(localUsers: [User], remoteUsers: [User]) -> Bool {
        guard localUsers.count == remoteUsers.count else {
            return true
        }
        
        let localDict = Dictionary(uniqueKeysWithValues: localUsers.map { ($0.id, $0) })
        
        for remoteUser in remoteUsers {
            guard let localUser = localDict[remoteUser.id] else {
                return true
            }
            
            if localUser.username != remoteUser.username ||
                localUser.sex != remoteUser.sex ||
                localUser.isOnline != remoteUser.isOnline ||
                localUser.age != remoteUser.age ||
                localUser.files != remoteUser.files {
                return true
            }
        }
        return false
    }
    
    func hasChangesStatistic(localStatistics: [UserStatistic], remoteStatistics: [UserStatistic]) -> Bool {
        guard localStatistics.count == remoteStatistics.count else {
            return true
        }
        let localDict = Dictionary(uniqueKeysWithValues: localStatistics.map { ($0.id, $0) })
        for remoteStatistic in remoteStatistics {
            guard let localStatistic = localDict[remoteStatistic.id] else {
                return true
            }
            
            if localStatistic.dates != remoteStatistic.dates ||
                localStatistic.type != remoteStatistic.type ||
                localStatistic.userId != remoteStatistic.userId ||
                localStatistic.id != remoteStatistic.id {
                return true
            }
        }
        return false
    }
}
