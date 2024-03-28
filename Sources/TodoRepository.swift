import Foundation

// Interface for storing and editing Todos
protocol TodoRepository {
    // create todo
    func create(title: String, order: Int?, urlPrefix: String) async throws -> Todo
    // get todo
    func get(id: UUID) async throws -> Todo?
    // list all todos
    func list() async throws -> [Todo]
    /// Update todo. Returns updated todo if successful
    func update(id: UUID, title: String?, order: Int?, completed: Bool?) async throws -> Todo?
    /// Delete todo. Returns true if successful
    func delete(id: UUID) async throws -> Bool
    /// Delete all todos
    func deleteAll() async throws
}
