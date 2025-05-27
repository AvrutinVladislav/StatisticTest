import Foundation
import RxSwift
import RxCocoa

final public class NetworkProvider: NetworkProviderProtocol {
        
    func fetchUsers() -> Observable<[User]> {
        guard let url = URL(string: "http://test.rikmasters.ru/api/users/") else {
            return Observable.error(NSError(domain: "Invalid URL", code: -1))
        }
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data -> [User] in
                do {
                    let response = try JSONDecoder().decode(UsersResponse.self, from: data)
                    return response.users
                } catch {
                    throw error
                }
            }
    }
    
    func fetchStatistics() -> Observable<[UserStatistic]> {
        guard let url = URL(string: "http://test.rikmasters.ru/api/statistics/") else {
            return Observable.error(NSError(domain: "Invalid URL", code: -1))
        }
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data -> [UserStatistic] in
                do {
                    let response = try JSONDecoder().decode(StatisticsResponse.self, from: data)
                    return response.statistics
                } catch {
                    throw error
                }
            }
    }

}
