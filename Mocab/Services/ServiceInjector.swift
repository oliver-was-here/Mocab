import Foundation

class ServiceInjector {
    static let termsService: TermService.Type = UserDefaultsTermService.self
    static let definer: TermDefiner.Type = OxfordDictionaryService.self
}
