import ArgumentParser
import Foundation

struct Reset: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Remove swiftcn and all installed components from your project"
    )

    @Flag(name: .shortAndLong, help: "Skip confirmation prompt")
    var yes: Bool = false

    func run() throws {
        // Check if initialized
        guard ConfigManager.exists() else {
            Logger.error("swiftcn is not initialized in this directory.")
            Logger.step("Nothing to remove.")
            return
        }

        let config = try ConfigManager.load()

        print("")
        Logger.warning("This will remove:")
        Logger.step("Design System folder: \(config.designSystemPath)/")
        Logger.step("Config file: swiftcn.json")
        Logger.step("All installed components and styles")
        print("")

        // Confirm unless --yes flag
        if !yes {
            print("Are you sure? This cannot be undone. [y/N]")
            print("> ", terminator: "")

            guard let input = readLine()?.lowercased(), input == "y" || input == "yes" else {
                Logger.info("Cancelled.")
                return
            }
        }

        print("")

        // Remove Design System directory
        do {
            let designSystemURL = FileHandler.currentDirectory.appendingPathComponent(config.designSystemPath)
            if FileHandler.fileManager.fileExists(atPath: designSystemURL.path) {
                try FileHandler.fileManager.removeItem(at: designSystemURL)
                Logger.success("Removed \(config.designSystemPath)/")
            }
        } catch {
            Logger.error("Failed to remove Design System folder: \(error.localizedDescription)")
        }

        // Remove config file
        do {
            try FileHandler.fileManager.removeItem(at: ConfigManager.configPath)
            Logger.success("Removed swiftcn.json")
        } catch {
            Logger.error("Failed to remove config: \(error.localizedDescription)")
        }

        print("")
        Logger.success("swiftcn has been removed from this project.")
        print("")
    }
}
