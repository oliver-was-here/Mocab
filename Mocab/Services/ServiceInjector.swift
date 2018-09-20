import Foundation

class ServiceInjector {
    static let termsService: TermService.Type = UserDefaultsTermService.self
}
