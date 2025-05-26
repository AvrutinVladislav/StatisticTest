import Foundation
import RxSwift

protocol NetworkProviderProtocol: AnyObject {
    func fetchUsers() -> Observable<[User]>
    func fetchStatistics() -> Observable<[UserStatistic]>
}
