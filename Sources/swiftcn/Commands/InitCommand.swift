import ArgumentParser
import Foundation

struct Init: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Initialize swiftcn in your project"
    )

    @Option(name: .shortAndLong, help: "Path for the Design System folder (default: auto-detected)")
    var path: String?

    @Flag(name: .shortAndLong, help: "Skip prompts and use defaults")
    var yes: Bool = false

    @Flag(name: .long, help: "Overwrite existing configuration")
    var force: Bool = false

    func run() throws {
        print("")
        print("Initializing swiftcn...")
        print("")

        // Check if already initialized
        if ConfigManager.exists() && !force {
            Logger.warning("swiftcn is already initialized in this directory.")
            Logger.step("Use --force to reinitialize.")
            return
        }

        // Detect project structure
        let sourceDir = FileHandler.findProjectSourceDirectory()

        // Determine base path
        let basePath: String
        if let sourceDir = sourceDir {
            basePath = sourceDir
            Logger.info("Detected project source: \(sourceDir)/")
        } else {
            basePath = "."
            Logger.warning("Could not detect project structure, using current directory.")
        }

        print("")

        // Get Design System path
        let designSystemPath: String
        if let providedPath = path {
            designSystemPath = providedPath
        } else if yes {
            // Use default
            designSystemPath = basePath == "." ? "DesignSystem" : "\(basePath)/DesignSystem"
        } else {
            // Prompt user
            let defaultPath = basePath == "." ? "DesignSystem" : "\(basePath)/DesignSystem"
            designSystemPath = promptForPath(
                message: "Where should the Design System be stored?",
                defaultValue: defaultPath
            )
        }

        // Components and Styles are subdirectories of Design System
        let componentsPath = "\(designSystemPath)/Components"
        let stylesPath = "\(designSystemPath)/Styles"

        print("")
        Logger.info("Design System path: \(designSystemPath)/")
        Logger.step("Components: \(componentsPath)/")
        Logger.step("Styles: \(stylesPath)/")
        print("")

        // Create config
        var config = Config()
        config.designSystemPath = designSystemPath
        config.componentsPath = componentsPath
        config.stylesPath = stylesPath

        // Create directories
        do {
            try FileHandler.createDirectory(at: componentsPath)
            Logger.success("Created \(componentsPath)/")

            try FileHandler.createDirectory(at: stylesPath)
            Logger.success("Created \(stylesPath)/")
        } catch {
            Logger.error("Failed to create directories: \(error.localizedDescription)")
            throw ExitCode.failure
        }

        // Fetch and install base style files
        print("")
        Logger.info("Fetching style files...")

        do {
            let registry = try awaitSync { await tryFetch() }

            guard let defaultStyle = registry.styles["default"] else {
                throw RegistryError.styleNotFound("default")
            }

            for file in defaultStyle.files {
                let content = try awaitSync { await tryFetchFile(path: file) }
                let fileName = URL(fileURLWithPath: file).lastPathComponent
                let destinationPath = "\(stylesPath)/\(fileName)"

                try FileHandler.writeFile(content: content, to: destinationPath)
                Logger.success("Added \(fileName)")

                // Track in config
                let itemName = fileName.replacingOccurrences(of: ".swift", with: "")
                config.installed.append(Config.InstalledItem(
                    name: itemName,
                    type: .style,
                    installedAt: Date()
                ))
            }
        } catch {
            Logger.error("Failed to fetch style files: \(error)")
            Logger.step("You can add them manually later.")
        }

        // Save config
        do {
            try ConfigManager.save(config)
            Logger.success("Created swiftcn.json")
        } catch {
            Logger.error("Failed to save config: \(error.localizedDescription)")
            throw ExitCode.failure
        }

        print("")
        Logger.success("swiftcn initialized!")
        print("")
        print("Next steps:")
        print("  1. Add the Design System folder to your Xcode project")
        print("  2. Add color assets to your Asset Catalog (Gray50-950, Error, Warning, Success)")
        print("  3. Add components with: swiftcn add Button")
        print("  4. List available components: swiftcn list")
        print("")
    }

    // MARK: - Prompts

    private func promptForPath(message: String, defaultValue: String) -> String {
        print("\(message)")
        print("Press Enter for default: \(defaultValue)")
        print("> ", terminator: "")

        guard let input = readLine(), !input.isEmpty else {
            return defaultValue
        }

        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Async Helpers

    private func tryFetch() async -> Registry? {
        try? await RegistryManager.fetch()
    }

    private func tryFetchFile(path: String) async -> String? {
        try? await RegistryManager.fetchFile(path: path)
    }
}

// MARK: - Sync/Async Bridge

/// Simple helper to run async code synchronously for CLI
func awaitSync<T>(_ operation: @escaping () async -> T?) throws -> T {
    let semaphore = DispatchSemaphore(value: 0)
    var result: T?

    Task {
        result = await operation()
        semaphore.signal()
    }

    semaphore.wait()

    guard let value = result else {
        throw NSError(domain: "swiftcn", code: 1, userInfo: [NSLocalizedDescriptionKey: "Async operation failed"])
    }

    return value
}
