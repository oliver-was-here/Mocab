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
        let url = OxfordDictionaryService.createInflectionsURL(word: normalizedWord)

        return firstly {
            Alamofire               // todo see about custom .validate()
                .request(url, headers: headers)
                .responseDecodable(InflectionResponse.self)
        }.compactMap { response in
            getRootWord(inflectionWord: normalizedWord, fromResponse: response)
        }.then { rootWord in
            requestDefinition(forRoot: rootWord)
        }.map { response in
            getDefinitions(fromResponse: response)
        }
    }
    
    // MARK: Private
    
    private static func requestDefinition(forRoot word: InflectionWord) -> Promise<DefinitionResponse> {
        let url = createEntriesURL(word: word.id)
        return Alamofire               // todo see about custom .validate()
            .request(url, headers: headers)
            .responseDecodable(DefinitionResponse.self)
    }
    
    private static func getRootWord(
        inflectionWord sourceInflection: String,
        fromResponse response: InflectionResponse
        ) -> InflectionWord? {
        let terms = response.results.flatMap {
            return $0.lexicalEntries.flatMap {
                return $0.inflectionOf
            }
        }
        
        return terms.first { $0.id == sourceInflection } ?? terms.first
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
