// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Hummingbird
import Logging

/// Arguments extracted from commandline
protocol AppArguments {
    var hostname: String { get}
    var port: Int { get }
    var inMemoryTesting: Bool { get }
}

@main
struct Todos: AsyncParsableCommand,  AppArguments {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    @Flag
    var inMemoryTesting: Bool = false

    mutating func run() async throws {
        // create application
        let app = try await buildApplication(self)
        // run the application
        try await app.runService()
    }
}



/// Build a Application
func buildApplication(_ args: some AppArguments) async throws -> some ApplicationProtocol {
    var logger = Logger(label: "Todos")
    logger.logLevel = .debug
    // create router
    let router = Router()
    // add logging middleware
    router.middlewares.add(LogRequestsMiddleware(.info))
    // add hello route
    router.get("/") { request, context in
        "Hello\n"
    }
    // add Todos API
    TodoController(repository: TodoMemoryRepository()).addRoutes(to: router.group("todos"))
    // create application
    let app = Application(
        router: router,
        configuration: .init(address: .hostname(args.hostname, port: args.port)),
        logger: logger
    )
    return app
}

