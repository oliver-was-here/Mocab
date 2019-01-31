import Foundation

class ServiceInjector {
    static let termsService: TermService.Type = RealmTermService.self
    static let listsService: ListService.Type = RealmListService.self
    static let definer: TermDefiner.Type = OxfordDictionaryService.self
}
