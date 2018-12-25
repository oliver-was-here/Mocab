import Foundation

class UserDefaultsTermService: TermService {
    private static let TERMS_KEY = "usersTerms-v2"
    private static let defaults = UserDefaults.standard
    
    // MARK: TermService
    static func getAll() -> [Term] {
        guard let learningTermsJson = defaults
            .object(forKey: self.TERMS_KEY) as? Data
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
        return getAll().first(where: { t in
            t.status == Term.Status.inProgress
        })
    }
    
    static func save(_ newTerm: Term, retainOrder: Bool) {
        let currTerms = getAll()
        let terms: [Term]
        if retainOrder {
            terms = currTerms.map {
                $0.id == newTerm.id ? newTerm : $0
            }
        } else {
            terms = getAll().filter { $0.id != newTerm.id } + [newTerm]
        }
        
        save(terms: terms)
    }
    
    // MARK: Private
    static private func save(terms: [Term]) {
        do {
            let encodedTerms = try JSONMapper.encoderInstance.encode(terms)
            defaults.set(encodedTerms, forKey: self.TERMS_KEY)
        } catch {
            print("ERROR: data-corruption in save([Term]): \(error)")
        }
    }
}
