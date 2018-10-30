import Foundation

class TermModelViewImplFactory {
    static func getViewModels(for status: Term.Status) -> [TermModelView] {
        return ServiceInjector.termsService
            .getAll()
            .filter { $0.status == status }
            .map { TermModelViewImpl(term: $0) }
    }
}
