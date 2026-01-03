import Foundation

enum FileHandler {
    static let fileManager = FileManager.default

    /// Get current working directory
    static var currentDirectory: URL {
        URL(fileURLWithPath: fileManager.currentDirectoryPath)
    }

    /// Create a directory if it doesn't exist
    static func createDirectory(at path: String) throws {
        let url = currentDirectory.appendingPathComponent(path)
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    /// Write content to a file
    static func writeFile(content: String, to path: String) throws {
        let url = currentDirectory.appendingPathComponent(path)

        // Create parent directory if needed
        let parentDir = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: parentDir.path) {
            try fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }

        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Check if a file exists
    static func fileExists(at path: String) -> Bool {
        let url = currentDirectory.appendingPathComponent(path)
        return fileManager.fileExists(atPath: url.path)
    }

    /// Find the iOS/macOS project source directory
    /// Looks for a directory containing Swift files (the main source folder)
    static func findProjectSourceDirectory() -> String? {
        let currentPath = currentDirectory.path

        // Common patterns for Xcode projects
        // Usually the source folder has the same name as the .xcodeproj (minus extension)
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: currentPath)

            // Look for .xcodeproj and derive source folder name
            if let xcodeproj = contents.first(where: { $0.hasSuffix(".xcodeproj") }) {
                let projectName = xcodeproj.replacingOccurrences(of: ".xcodeproj", with: "")
                let sourcePath = currentDirectory.appendingPathComponent(projectName)

                if fileManager.fileExists(atPath: sourcePath.path) {
                    return projectName
                }
            }

            // Fallback: look for common source directories
            let commonNames = ["Sources", "Source", "App", "src"]
            for name in commonNames {
                let path = currentDirectory.appendingPathComponent(name)
                if fileManager.fileExists(atPath: path.path) {
                    return name
                }
            }

        } catch {
            return nil
        }

        return nil
    }
}
