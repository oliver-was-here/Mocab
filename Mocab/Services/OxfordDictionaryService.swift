import Foundation
import PromiseKit
import PMKAlamofire
import UIKit

class OxfordDictionaryService: TermDefiner {
    private static let baseURL = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1")!
    private static let inflectionsEndpoint = baseURL.appendingPathComponent("inflections")
    private static let definitionsEndpoint = baseURL.appendingPathComponent("entries")
    
    //    #error("update appId")
    private static let appId = ""
    //    #error("update appKey")
    private static let appKey = ""


    private static let headers: HTTPHeaders = [
        "app_id": appId,
        "app_key": appKey,
        "Accept": "application/json"
    ]
    
    static func getDefinitions(forTerm term: String) -> Promise<[String]> {
        let normalizedTerm = term
            .lowercased()
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    
        if !validTerm(term: normalizedTerm) {
            return Promise.value([])
        }
        
        return firstly {
            requestDefinition(forRoot: normalizedTerm)
        }.map { response in
            getDefinitions(fromResponse: response)
        }
    }
    
    // MARK: Private
    
    static private func validTerm(term: String) -> Bool {
        if term.split(separator: " ").count > 1 {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: term.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: term,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )
        
        return misspelledRange.location == NSNotFound
    }
    
    private static func requestDefinition(forRoot term: String) -> Promise<DefinitionResponse> {
        let url = createEntriesURL(term: term)
        return Alamofire               // todo see about custom .validate()
            .request(url, headers: headers)
            .responseDecodable(DefinitionResponse.self)
    }
    
    private static func getDefinitions(
        fromResponse response: DefinitionResponse
        ) -> [String] {
        return response.results.flatMap {
            $0.lexicalEntries.flatMap {
                $0.entries.flatMap {
                    $0.senses.flatMap {
                        $0.definitions
                    }
                }
            }
        }
    }

    private static func createInflectionsURL(term: String, language: Language = .en) -> URL {
        return inflectionsEndpoint
            .appendingPathComponent("\(language)")
            .appendingPathComponent(term)
    }
    
    private static func createEntriesURL(term: String, language: Language = .en) -> URL {
        return definitionsEndpoint
            .appendingPathComponent("\(language)")
            .appendingPathComponent(term)
    }
}
