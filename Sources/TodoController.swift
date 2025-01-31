import Hummingbird
import Foundation

struct TodoController<Context: RequestContext, Repository: TodoRepository> {
    // Todo repository
    let repository: Repository

    func addRoutes(to group: RouterGroup<Context>) {
        group
          .get(":id", use: get)
          .get(use: list)
          .post(use: create)
          .patch(":id", use: update)
          .delete(":id", use: delete)
          .delete(use: deleteAll)
    }

    @Sendable func get(request: Request, context:Context) async throws -> Todo? {
      let id = try context.parameters.require("id", as: UUID.self)
      return try await self.repository.get(id: id)
    }

    struct CreateRequest: Decodable {
        let title: String
        let order: Int?
    }
    /// Create todo entrypoint
    @Sendable
    func create(request: Request, context: Context) async throws -> EditedResponse<Todo> {
        let request = try await request.decode(as: CreateRequest.self, context: context)
        let todo = try await self.repository.create(title: request.title, order: request.order, urlPrefix: "http://localhost:8080/todos/")
        return EditedResponse(status: .created, response: todo)
    }

    @Sendable
    func list(request: Request, context: Context) async throws -> [Todo] {
      return try await self.repository.list()
    }

     struct UpdateRequest: Decodable {
        let title: String?
        let order: Int?
        let completed: Bool?
    }

    @Sendable
    func update(request: Request, context: Context) async throws -> Todo? {
        let id = try context.parameters.require("id", as: UUID.self)
        let request  = try await request.decode(as: UpdateRequest.self, context: context)

        guard let todo = try await self.repository.update(
            id: id,
            title: request.title,
            order: request.order,
            completed: request.completed
        ) else {
            throw HTTPError(.badRequest)
        }
        return todo
    }

     /// Delete todo entrypoint
    @Sendable
    func delete(request: Request, context: Context) async throws -> HTTPResponse.Status {
        let id = try context.parameters.require("id", as: UUID.self)
        if try await self.repository.delete(id: id) {
            return .ok
        } else {
            return .badRequest
        }
    }

    /// Delete all todos entrypoint
    @Sendable
    func deleteAll(request: Request, context: Context) async throws -> HTTPResponse.Status {
        try await self.repository.deleteAll()
        return .ok
    }

}
