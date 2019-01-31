import Foundation

protocol ListService {
    static func getAll() -> [(id: String, name: String)]
}
