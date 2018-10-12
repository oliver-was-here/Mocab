import Foundation

class UserDefaultsTermService: TermService {
    private static let TERMS_KEY = "usersTerms"
    private static let defaults = UserDefaults.standard
    
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
    
    static func save(_ newTerm: Term) {
        let terms = filterDuplicates(terms: [newTerm] + getAll())
        save(terms: terms)
    }
    
    static func delete(_ term: Term) {
        let updatedTerms = getAll().filter { $0.id != term.id }
        save(terms: updatedTerms)
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
    
    static private func filterDuplicates(terms: [Term]) -> [Term] {
        var takenTerms: Set<String> = Set()
        return terms.filter {
            let (inserted, _) = takenTerms.insert($0.id)
            return inserted
        }
    }
}
