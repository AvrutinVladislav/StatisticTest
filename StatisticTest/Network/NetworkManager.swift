import Foundation
import RxSwift
import RxCocoa

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
        
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
    
    func fetchStatistics() -> Observable<StatisticsResponse> {
        guard let url = URL(string: "http://test.rikmasters.ru/api/statistics/") else {
            return Observable.error(NSError(domain: "Invalid URL", code: -1))
        }
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data -> StatisticsResponse in
                do {
                    return try JSONDecoder().decode(StatisticsResponse.self, from: data)
                } catch {
                    throw error
                }
            }
    }

}
