import Foundation
import PromiseKit

protocol TermDefiner {
    static func getDefinitions(forWord word: String) -> Promise<[String]>
}
