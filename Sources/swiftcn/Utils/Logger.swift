import Foundation

enum Logger {
    static func success(_ message: String) {
        print("✓ \(message)")
    }

    static func error(_ message: String) {
        print("✗ \(message)")
    }

    static func warning(_ message: String) {
        print("⚠ \(message)")
    }

    static func info(_ message: String) {
        print("→ \(message)")
    }

    static func step(_ message: String) {
        print("  \(message)")
    }

    static func newLine() {
        print("")
    }
}
