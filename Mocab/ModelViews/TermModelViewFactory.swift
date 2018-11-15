import Foundation

class TermModelViewImplFactory {
    static func getViewModels(
        for status: Term.Status,
        statusUpdated: @escaping () -> (),
        numLinesUpdated: @escaping (TermModelView, IndexPath) -> ()
    ) -> [TermModelView] {
        return ServiceInjector.termsService
            .getAll()
            .filter { $0.status == status }
            .map { TermModelViewImpl(
                term: $0,
                statusUpdated: statusUpdated,
                numLinesUpdated: numLinesUpdated
            ) }
    }
}
