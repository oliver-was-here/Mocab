import Foundation

struct DefinitionResponse: Decodable {
    let results: [DefinitionResult]
}

struct DefinitionResult: Decodable {
    let lexicalEntries: [DefinitionLexicalEntry]
}

struct DefinitionLexicalEntry: Decodable {
    let entries: [DefinitionEntry]
}

struct DefinitionEntry: Decodable {
    let senses: [DefinitionSense]
}

struct DefinitionSense: Decodable {
    let definitions: [String]
}
