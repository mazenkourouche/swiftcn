import SwiftUI

// MARK: - AppIcon Enum

/// Add your app's icons here. Use SF Symbols names or asset catalog names.
public enum AppIcon: String, CaseIterable {
    // Common UI icons (SF Symbols)
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case chevronDown = "chevron.down"
    case chevronUp = "chevron.up"
    case xmark = "xmark"
    case xmarkCircleFill = "xmark.circle.fill"
    case checkmark = "checkmark"
    case plus = "plus"
    case minus = "minus"
    case search = "magnifyingglass"
    case eye = "eye"
    case eyeSlash = "eye.slash"
    case gear = "gear"
    case person = "person"
    case heart = "heart"
    case heartFill = "heart.fill"
    case star = "star"
    case starFill = "star.fill"
    case trash = "trash"
    case pencil = "pencil"
    case ellipsis = "ellipsis"
    case house = "house"
    case houseFill = "house.fill"
    case bell = "bell"
    case bellFill = "bell.fill"
    case bookmark = "bookmark"
    case bookmarkFill = "bookmark.fill"
    case cart = "cart"
    case cartFill = "cart.fill"

    // Add your custom icons below...
}

// MARK: - Icon Sizes

public enum IconSize {
    /// Extra small icon (12pt)
    case xs
    /// Small icon (16pt)
    case sm
    /// Medium icon (20pt)
    case md
    /// Large icon (24pt)
    case lg
    /// Extra large icon (32pt)
    case xl
    /// Custom size
    case custom(CGFloat)

    public var value: CGFloat {
        switch self {
        case .xs: return 12
        case .sm: return 16
        case .md: return 20
        case .lg: return 24
        case .xl: return 32
        case .custom(let size): return size
        }
    }
}

// MARK: - Icon Styles

public enum IconStyle {
    /// Primary foreground color
    case primary
    /// Secondary/muted color
    case secondary
    /// Destructive/error color
    case destructive
    /// Custom color
    case custom(Color)

    public var color: Color {
        switch self {
        case .primary:
            return TokenText.primary
        case .secondary:
            return TokenText.secondary
        case .destructive:
            return TokenText.destructive
        case .custom(let color):
            return color
        }
    }
}

// MARK: - Icon View

/// A flexible icon view that supports multiple image sources with consistent sizing and styling.
public struct Icon: View {

    public enum Source {
        case appIcon(AppIcon)
        case system(String)
        case asset(String)
        case image(Image)
    }

    private let source: Source
    private let size: IconSize
    private let style: IconStyle
    private let preserveOriginalColor: Bool

    // MARK: - Initializers

    /// Create an icon from an AppIcon enum case
    public init(
        _ icon: AppIcon,
        size: IconSize = .md,
        style: IconStyle = .primary
    ) {
        self.source = .appIcon(icon)
        self.size = size
        self.style = style
        self.preserveOriginalColor = false
    }

    /// Create an icon from an SF Symbol name
    public init(
        systemName: String,
        size: IconSize = .md,
        style: IconStyle = .primary
    ) {
        self.source = .system(systemName)
        self.size = size
        self.style = style
        self.preserveOriginalColor = false
    }

    /// Create an icon from an asset catalog image
    public init(
        name: String,
        size: IconSize = .md,
        style: IconStyle = .primary,
        preserveOriginalColor: Bool = false
    ) {
        self.source = .asset(name)
        self.size = size
        self.style = style
        self.preserveOriginalColor = preserveOriginalColor
    }

    /// Create an icon from any Image
    public init(
        image: Image,
        size: IconSize = .md,
        style: IconStyle = .primary,
        preserveOriginalColor: Bool = false
    ) {
        self.source = .image(image)
        self.size = size
        self.style = style
        self.preserveOriginalColor = preserveOriginalColor
    }

    // MARK: - Body

    public var body: some View {
        iconImage
            .frame(width: size.value, height: size.value)
    }

    @ViewBuilder
    private var iconImage: some View {
        switch source {
        case .appIcon(let icon):
            Image(systemName: icon.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(style.color)

        case .system(let name):
            Image(systemName: name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(style.color)

        case .asset(let name):
            Image(name)
                .resizable()
                .renderingMode(preserveOriginalColor ? .original : .template)
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(preserveOriginalColor ? .primary : style.color)

        case .image(let image):
            image
                .resizable()
                .renderingMode(preserveOriginalColor ? .original : .template)
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(preserveOriginalColor ? .primary : style.color)
        }
    }
}

// MARK: - Convenience Initializers

public extension Icon {
    /// Create an icon with a custom color
    static func custom(
        _ icon: AppIcon,
        size: IconSize = .md,
        color: Color
    ) -> Icon {
        Icon(icon, size: size, style: .custom(color))
    }

    /// Create an icon from system name with custom color
    static func custom(
        systemName: String,
        size: IconSize = .md,
        color: Color
    ) -> Icon {
        Icon(systemName: systemName, size: size, style: .custom(color))
    }
}
