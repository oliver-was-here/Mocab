import Foundation
import PromiseKit

protocol TermDefiner {
    static func getDefinitions(forTerm term: String) -> Promise<[String]>
}
