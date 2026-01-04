import SwiftUI

// MARK: - Avatar Size

/// Size variants for SCAvatar
public enum SCAvatarSize {
    /// Extra small avatar (24pt)
    case xs
    /// Small avatar (32pt)
    case sm
    /// Medium avatar (40pt)
    case md
    /// Large avatar (48pt)
    case lg
    /// Extra large avatar (64pt)
    case xl
    /// Custom size
    case custom(CGFloat)

    var dimension: CGFloat {
        switch self {
        case .xs: return 24
        case .sm: return 32
        case .md: return 40
        case .lg: return 48
        case .xl: return 64
        case .custom(let size): return size
        }
    }

    var font: Font {
        switch self {
        case .xs: return .system(size: 10, weight: .medium)
        case .sm: return .system(size: 12, weight: .medium)
        case .md: return .system(size: 14, weight: .medium)
        case .lg: return .system(size: 16, weight: .semibold)
        case .xl: return .system(size: 20, weight: .semibold)
        case .custom(let size): return .system(size: size * 0.35, weight: .medium)
        }
    }

    var iconSize: IconSize {
        switch self {
        case .xs: return .xs
        case .sm: return .sm
        case .md: return .sm
        case .lg: return .md
        case .xl: return .lg
        case .custom: return .md
        }
    }
}

// MARK: - Avatar Shape

/// Shape variants for SCAvatar
public enum SCAvatarShape {
    /// Circular avatar
    case circle
    /// Rounded square avatar
    case rounded
    /// Square avatar
    case square

    func clipShape(size: CGFloat) -> some Shape {
        switch self {
        case .circle:
            return AnyShape(Circle())
        case .rounded:
            return AnyShape(RoundedRectangle(cornerRadius: size * 0.2))
        case .square:
            return AnyShape(RoundedRectangle(cornerRadius: TokenRadius.sm))
        }
    }
}

// MARK: - AnyShape Helper

private struct AnyShape: Shape {
    private let pathBuilder: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        pathBuilder = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

// MARK: - Avatar

/// An image element with a fallback for representing a user
public struct SCAvatar: View {
    private let imageURL: URL?
    private let image: Image?
    private let initials: String?
    private let icon: AppIcon?
    private let size: SCAvatarSize
    private let shape: SCAvatarShape
    private let backgroundColor: Color?
    private let foregroundColor: Color?

    // MARK: - Initializers

    /// Creates an avatar with a remote image URL
    public init(
        url: URL?,
        initials: String? = nil,
        size: SCAvatarSize = .md,
        shape: SCAvatarShape = .circle,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil
    ) {
        self.imageURL = url
        self.image = nil
        self.initials = initials
        self.icon = nil
        self.size = size
        self.shape = shape
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    /// Creates an avatar with a local image
    public init(
        image: Image,
        initials: String? = nil,
        size: SCAvatarSize = .md,
        shape: SCAvatarShape = .circle
    ) {
        self.imageURL = nil
        self.image = image
        self.initials = initials
        self.icon = nil
        self.size = size
        self.shape = shape
        self.backgroundColor = nil
        self.foregroundColor = nil
    }

    /// Creates an avatar with initials only
    public init(
        initials: String,
        size: SCAvatarSize = .md,
        shape: SCAvatarShape = .circle,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil
    ) {
        self.imageURL = nil
        self.image = nil
        self.initials = initials
        self.icon = nil
        self.size = size
        self.shape = shape
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    /// Creates an avatar with an icon fallback
    public init(
        url: URL? = nil,
        icon: AppIcon,
        size: SCAvatarSize = .md,
        shape: SCAvatarShape = .circle,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil
    ) {
        self.imageURL = url
        self.image = nil
        self.initials = nil
        self.icon = icon
        self.size = size
        self.shape = shape
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if let image = image {
                // Local image
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let url = imageURL {
                // Remote image with async loading
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let loadedImage):
                        loadedImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        fallbackView
                    @unknown default:
                        fallbackView
                    }
                }
            } else {
                // Fallback only
                fallbackView
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(shape.clipShape(size: size.dimension))
    }

    // MARK: - Fallback View

    @ViewBuilder
    private var fallbackView: some View {
        ZStack {
            (backgroundColor ?? TokenSurface.muted)

            if let initials = initials {
                Text(formattedInitials(initials))
                    .font(size.font)
                    .foregroundStyle(foregroundColor ?? TokenText.secondary)
            } else if let icon = icon {
                Icon(icon, size: size.iconSize, style: .custom(foregroundColor ?? TokenText.secondary))
            } else {
                Icon(.person, size: size.iconSize, style: .custom(foregroundColor ?? TokenText.secondary))
            }
        }
    }

    // MARK: - Helpers

    private func formattedInitials(_ text: String) -> String {
        let words = text.split(separator: " ")
        if words.count >= 2 {
            let first = words[0].prefix(1)
            let second = words[1].prefix(1)
            return "\(first)\(second)".uppercased()
        }
        return String(text.prefix(2)).uppercased()
    }
}

// MARK: - Avatar Group

/// A horizontal stack of overlapping avatars
public struct SCAvatarGroup: View {
    private let avatars: [AvatarData]
    private let size: SCAvatarSize
    private let maxDisplay: Int
    private let overlap: CGFloat

    public struct AvatarData: Identifiable {
        public let id = UUID()
        public let url: URL?
        public let initials: String?

        public init(url: URL?, initials: String? = nil) {
            self.url = url
            self.initials = initials
        }

        public init(initials: String) {
            self.url = nil
            self.initials = initials
        }
    }

    public init(
        avatars: [AvatarData],
        size: SCAvatarSize = .sm,
        maxDisplay: Int = 4,
        overlap: CGFloat = 0.3
    ) {
        self.avatars = avatars
        self.size = size
        self.maxDisplay = maxDisplay
        self.overlap = overlap
    }

    public var body: some View {
        HStack(spacing: -(size.dimension * overlap)) {
            ForEach(Array(displayedAvatars.enumerated()), id: \.element.id) { index, avatar in
                SCAvatar(url: avatar.url, initials: avatar.initials, size: size)
                    .overlay(
                        Circle()
                            .stroke(TokenSurface.primary, lineWidth: 2)
                    )
                    .zIndex(Double(displayedAvatars.count - index))
            }

            if remainingCount > 0 {
                SCAvatar(
                    initials: "+\(remainingCount)",
                    size: size,
                    backgroundColor: TokenSurface.secondary,
                    foregroundColor: TokenText.primary
                )
                .overlay(
                    Circle()
                        .stroke(TokenSurface.primary, lineWidth: 2)
                )
            }
        }
    }

    private var displayedAvatars: [AvatarData] {
        Array(avatars.prefix(maxDisplay))
    }

    private var remainingCount: Int {
        max(0, avatars.count - maxDisplay)
    }
}

// MARK: - Convenience Initializers

public extension SCAvatar {
    /// Creates an avatar from a URL string
    static func url(
        _ urlString: String,
        initials: String? = nil,
        size: SCAvatarSize = .md
    ) -> SCAvatar {
        SCAvatar(
            url: URL(string: urlString),
            initials: initials,
            size: size
        )
    }

    /// Creates an avatar with a person's name (auto-generates initials)
    static func name(
        _ name: String,
        url: URL? = nil,
        size: SCAvatarSize = .md
    ) -> SCAvatar {
        SCAvatar(
            url: url,
            initials: name,
            size: size
        )
    }

    /// Creates a placeholder avatar with default icon
    static func placeholder(
        size: SCAvatarSize = .md
    ) -> SCAvatar {
        SCAvatar(
            icon: .person,
            size: size
        )
    }
}
