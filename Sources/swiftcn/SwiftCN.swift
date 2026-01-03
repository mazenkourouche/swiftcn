import ArgumentParser

@main
struct SwiftCN: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swiftcn",
        abstract: "A CLI tool for adding SwiftUI components to your project",
        version: "0.1.0",
        subcommands: [Init.self, Add.self, List.self, Reset.self]
    )
}
