import Foundation

class ListsViewModel {
    private let listsService = ServiceInjector.listsService
    private var listIDs: Set<String> = []
    
    private let receivedNewLists: ([ListViewModel]) -> ()
    private var lists: [ListViewModel] = [] {
        didSet {
            let newLists = lists.filter { !listIDs.contains($0.id) }
            newLists.forEach { listIDs.insert($0.id) }
            
            self.receivedNewLists(newLists)
        }
    }
    
    init(receivedNewLists: @escaping ([ListViewModel]) -> ()) {
        self.receivedNewLists = receivedNewLists
        
        defer {
            self.lists = listsService.getAll().map { ListViewModel(id: $0.id, name: $0.name) }
        }
    }
}
