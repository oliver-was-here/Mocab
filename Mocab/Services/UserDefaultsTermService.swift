import Foundation

class UserDefaultsTermService: TermService {
    private static let LEARNING_TERMS_KEY = "learningWords"
    private static let defaults = UserDefaults.standard
    
    static func getAll() -> [Term] {
        guard let learningTermsJson = defaults
            .object(forKey: self.LEARNING_TERMS_KEY) as? Data
            else {
                return [Term]()
            }
        
        do {
            return try JSONMapper
                .decoderInstance
                .decode([Term].self, from: learningTermsJson)
        } catch {
            print("ERROR: data-corruption in getAll()->Term: \(error)")
            return [Term]()
        }
    }
    
    static func getInProgressTerm() -> Term? {
        return getAll().first
    }
    
    static func create(_ newTerm: Term) {
        let terms = [newTerm] + getAll()
        do {
            let encodedTerms = try JSONMapper.encoderInstance.encode(terms)
            defaults.set(encodedTerms, forKey: self.LEARNING_TERMS_KEY)
        } catch {
            print("ERROR: data-corruption in create(Term): \(error)")
        }
    }
}
