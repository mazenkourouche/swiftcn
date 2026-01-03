import Foundation

/// Remote registry structure (registry.json)
struct Registry: Codable {
    let version: String
    let styles: [String: StyleInfo]
    let components: [String: ComponentInfo]

    struct StyleInfo: Codable {
        let name: String
        let description: String
        let files: [String]
    }

    struct ComponentInfo: Codable {
        let file: String
        let description: String
        let dependencies: [String]
    }
}

// MARK: - Registry Manager

enum RegistryManager {
    // GitHub raw URL for the registry
    static let baseURL = "https://raw.githubusercontent.com/mazenkourouche/swiftcn/main/Registry"
    static let registryURL = "\(baseURL)/registry.json"

    static func fetch() async throws -> Registry {
        guard let url = URL(string: registryURL) else {
            throw RegistryError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RegistryError.fetchFailed
        }

        let decoder = JSONDecoder()
        return try decoder.decode(Registry.self, from: data)
    }

    static func fetchFile(path: String) async throws -> String {
        let urlString = "\(baseURL)/\(path)"
        guard let url = URL(string: urlString) else {
            throw RegistryError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RegistryError.fetchFailed
        }

        guard let content = String(data: data, encoding: .utf8) else {
            throw RegistryError.invalidContent
        }

        return content
    }
}

enum RegistryError: Error, CustomStringConvertible {
    case invalidURL
    case fetchFailed
    case invalidContent
    case componentNotFound(String)
    case styleNotFound(String)

    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid registry URL"
        case .fetchFailed:
            return "Failed to fetch from registry"
        case .invalidContent:
            return "Invalid content received"
        case .componentNotFound(let name):
            return "Component '\(name)' not found in registry"
        case .styleNotFound(let name):
            return "Style '\(name)' not found in registry"
        }
    }
}
