import ArgumentParser
import Foundation

struct Add: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Add a component to your project"
    )

    @Argument(help: "The component to add (e.g., Button, Card)")
    var component: String

    @Flag(name: .long, help: "Overwrite if component already exists")
    var force: Bool = false

    func run() throws {
        // Check if initialized
        guard ConfigManager.exists() else {
            Logger.error("swiftcn is not initialized in this directory.")
            Logger.step("Run 'swiftcn init' first.")
            throw ExitCode.failure
        }

        let config = try ConfigManager.load()

        print("")
        Logger.info("Adding \(component)...")

        // Check if already installed
        if try ConfigManager.isInstalled(name: component) && !force {
            Logger.warning("\(component) is already installed.")
            Logger.step("Use --force to overwrite.")
            return
        }

        // Fetch registry
        let registry: Registry
        do {
            registry = try awaitSync { await tryFetch() }
        } catch {
            Logger.error("Failed to fetch registry: \(error)")
            throw ExitCode.failure
        }

        // Find component
        guard let componentInfo = registry.components[component] else {
            Logger.error("Component '\(component)' not found.")
            Logger.step("Run 'swiftcn list' to see available components.")
            throw ExitCode.failure
        }

        // Check dependencies
        for dependency in componentInfo.dependencies {
            let isInstalled = try ConfigManager.isInstalled(name: dependency)
            if !isInstalled {
                // Check if it's a style dependency
                if registry.styles["default"]?.files.contains(where: { $0.contains(dependency) }) == true {
                    Logger.success("\(dependency) (already installed)")
                } else if registry.components[dependency] != nil {
                    Logger.warning("\(dependency) is required but not installed.")
                    Logger.step("Installing \(dependency)...")

                    // Recursively install dependency
                    try installComponent(dependency, from: registry, config: config)
                }
            } else {
                Logger.success("\(dependency) (already installed)")
            }
        }

        // Install the component
        try installComponent(component, from: registry, config: config)

        print("")
        Logger.success("\(component) added successfully!")
        print("")
    }

    private func installComponent(_ name: String, from registry: Registry, config: Config) throws {
        guard let componentInfo = registry.components[name] else {
            throw RegistryError.componentNotFound(name)
        }

        // Fetch component file
        let content: String
        do {
            content = try awaitSync { await tryFetchFile(path: componentInfo.file) }
        } catch {
            Logger.error("Failed to fetch \(name): \(error)")
            throw ExitCode.failure
        }

        // Write to project
        let fileName = URL(fileURLWithPath: componentInfo.file).lastPathComponent
        let destinationPath = "\(config.componentsPath)/\(fileName)"

        do {
            try FileHandler.writeFile(content: content, to: destinationPath)
            try ConfigManager.addInstalledItem(name: name, type: .component)
            Logger.success("Added \(fileName)")
        } catch {
            Logger.error("Failed to write \(name): \(error)")
            throw ExitCode.failure
        }
    }

    // MARK: - Async Helpers

    private func tryFetch() async -> Registry? {
        try? await RegistryManager.fetch()
    }

    private func tryFetchFile(path: String) async -> String? {
        try? await RegistryManager.fetchFile(path: path)
    }
}
