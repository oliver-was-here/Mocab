import Foundation

struct DefinitionResponse: Codable {
    let results: [DefinitionResult]
}

struct DefinitionResult: Codable {
    let lexicalEntries: [DefinitionLexicalEntry]
}

struct DefinitionLexicalEntry: Codable {
    let entries: [DefinitionEntry]
}

struct DefinitionEntry: Codable {
    let senses: [DefinitionSense]
}

struct DefinitionSense: Codable {
    let definitions: [String]
}
