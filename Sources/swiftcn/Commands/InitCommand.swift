import ArgumentParser
import Foundation

struct Init: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Initialize swiftcn in your project"
    )

    @Option(name: .long, help: "Path for components (default: auto-detected)")
    var componentsPath: String?

    @Option(name: .long, help: "Path for styles (default: auto-detected)")
    var stylesPath: String?

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

        // Determine paths
        let finalComponentsPath: String
        let finalStylesPath: String

        if let sourceDir = sourceDir {
            finalComponentsPath = componentsPath ?? "\(sourceDir)/Components/UI"
            finalStylesPath = stylesPath ?? "\(sourceDir)/Styles"
            Logger.info("Detected project source: \(sourceDir)/")
        } else {
            finalComponentsPath = componentsPath ?? "Components/UI"
            finalStylesPath = stylesPath ?? "Styles"
            Logger.warning("Could not detect project structure, using current directory.")
        }

        print("")

        // Create config
        var config = Config()
        config.componentsPath = finalComponentsPath
        config.stylesPath = finalStylesPath

        // Create directories
        do {
            try FileHandler.createDirectory(at: finalComponentsPath)
            Logger.success("Created \(finalComponentsPath)/")

            try FileHandler.createDirectory(at: finalStylesPath)
            Logger.success("Created \(finalStylesPath)/")
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
                let destinationPath = "\(finalStylesPath)/\(fileName)"

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
            Logger.step("You can add them manually later with: swiftcn add Tokens")
            // Continue without failing - user can add later
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
        print("  1. Add color assets to your Asset Catalog (Gray50-950, Error, Warning, Success)")
        print("  2. Add components with: swiftcn add Button")
        print("  3. List available components: swiftcn list")
        print("")
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
