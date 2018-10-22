import Foundation
import PromiseKit
import PMKAlamofire

class OxfordDictionaryService: TermDefiner {
    private static let baseURL = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1")!
    private static let inflectionsEndpoint = baseURL.appendingPathComponent("inflections")
    private static let definitionsEndpoint = baseURL.appendingPathComponent("entries")
    
    #error("update appId")
    private static let appId = ""
    #error("update appKey")
    private static let appKey = ""

    private static let headers: HTTPHeaders = [
        "app_id": appId,
        "app_key": appKey,
        "Accept": "application/json"
    ]
    
    static func getDefinitions(forWord word: String) -> Promise<[String]> {
        let normalizedWord = word.lowercased()
    
        if !validWord(word: normalizedWord) {
            return Promise.value([])
        }
        
        return firstly {
            requestDefinition(forRoot: normalizedWord)
        }.map { response in
            getDefinitions(fromResponse: response)
        }
    }
    
    // MARK: Private
    
    static private func validWord(word: String) -> Bool {
        if word.split(separator: " ").count > 1 {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )
        
        return misspelledRange.location == NSNotFound
    }
    
    private static func requestDefinition(forRoot word: String) -> Promise<DefinitionResponse> {
        let url = createEntriesURL(word: word)
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

    private static func createInflectionsURL(word: String, language: Language = .en) -> URL {
        return inflectionsEndpoint
            .appendingPathComponent("\(language)")
            .appendingPathComponent(word)
    }
    
    private static func createEntriesURL(word: String, language: Language = .en) -> URL {
        return definitionsEndpoint
            .appendingPathComponent("\(language)")
            .appendingPathComponent(word)
    }
}
