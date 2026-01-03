import Foundation

/// Configuration file structure (swiftcn.json)
struct Config: Codable {
    var version: String = "1.0"
    var designSystemPath: String = "DesignSystem"
    var componentsPath: String = "DesignSystem/Components"
    var stylesPath: String = "DesignSystem/Styles"
    var style: String = "default"
    var installed: [InstalledItem] = []

    struct InstalledItem: Codable {
        let name: String
        let type: ItemType
        let installedAt: Date

        enum ItemType: String, Codable {
            case style
            case component
        }
    }
}

// MARK: - Config Manager

enum ConfigManager {
    static let fileName = "swiftcn.json"

    static var configPath: URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(fileName)
    }

    static func exists() -> Bool {
        FileManager.default.fileExists(atPath: configPath.path)
    }

    static func load() throws -> Config {
        let data = try Data(contentsOf: configPath)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Config.self, from: data)
    }

    static func save(_ config: Config) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(config)
        try data.write(to: configPath)
    }

    static func addInstalledItem(name: String, type: Config.InstalledItem.ItemType) throws {
        var config = try load()

        // Don't add duplicates
        guard !config.installed.contains(where: { $0.name == name && $0.type == type }) else {
            return
        }

        config.installed.append(Config.InstalledItem(
            name: name,
            type: type,
            installedAt: Date()
        ))

        try save(config)
    }

    static func isInstalled(name: String) throws -> Bool {
        let config = try load()
        return config.installed.contains { $0.name == name }
    }
}
