import Combine
import Foundation

enum ListItemAPI {
    static func fetchUsers() -> AnyPublisher<[ListItemModel], Error> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ListItemModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
