import ArgumentParser
import Foundation

struct List: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "List available components"
    )

    @Flag(name: .long, help: "Only show installed components")
    var installed: Bool = false

    func run() throws {
        // Fetch registry
        let registry: Registry
        do {
            registry = try awaitSync { await tryFetch() }
        } catch {
            Logger.error("Failed to fetch registry: \(error)")
            throw ExitCode.failure
        }

        // Load config if exists
        let config = try? ConfigManager.load()
        let installedNames = Set(config?.installed.map { $0.name } ?? [])

        print("")
        print("Available components:")
        print("")

        // Calculate padding for alignment
        let maxNameLength = registry.components.keys.map { $0.count }.max() ?? 0

        var installedCount = 0
        let sortedComponents = registry.components.sorted { $0.key < $1.key }

        for (name, info) in sortedComponents {
            let isInstalled = installedNames.contains(name)

            if self.installed && !isInstalled {
                continue
            }

            if isInstalled {
                installedCount += 1
            }

            let padding = String(repeating: " ", count: maxNameLength - name.count + 2)
            let status = isInstalled ? "[installed]" : ""
            let statusColor = isInstalled ? "  \(status)" : ""

            print("  \(name)\(padding)\(info.description)\(statusColor)")
        }

        print("")
        print("Installed: \(installedCount)/\(registry.components.count)")
        print("")
    }

    // MARK: - Async Helpers

    private func tryFetch() async -> Registry? {
        try? await RegistryManager.fetch()
    }
}
