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
    
    private enum CodingKeys: String, CodingKey {
        case senses
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let senses = try container.decode([DecodableDefinitionSense].self, forKey: .senses)
        
        self.senses = senses.compactMap {
            $0.definitions
        }.map {
            DefinitionSense(definitions: $0)
        }
    }
}

struct DecodableDefinitionSense: Decodable {
    // optional as structure is variant (e.g. subsenses returned by "cat")
    let definitions: [String]?
}

struct DefinitionSense {
    let definitions: [String]
}
