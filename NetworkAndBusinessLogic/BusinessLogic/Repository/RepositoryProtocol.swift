import Foundation

protocol RepositoryProtocol: AnyObject {
    func getLocalUsers() throws -> [User]
    func saveUsers(_ users: [User]) throws
    func updateUsers(_ users: [User]) throws
    func hasChanges(localUsers: [User], remoteUsers: [User]) -> Bool
    func getLocalStatistic() throws -> [UserStatistic]
    func saveStatistic(_ users: [UserStatistic]) throws
    func updateStatistic(_ statistics: [UserStatistic]) throws
    func hasChangesStatistic(localStatistics: [UserStatistic], remoteStatistics: [UserStatistic]) -> Bool
}
