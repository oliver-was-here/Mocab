import Foundation

struct InflectionResponse: Codable {
    let results: [InflectionResult]
}

struct InflectionResult: Codable {
    let lexicalEntries: [InflectionLexicalEntry]
}

struct InflectionLexicalEntry: Codable {
    let inflectionOf: [InflectionTerm]
}

struct InflectionTerm: Codable {
    let id: String
}
