import SwiftUI

// MARK: - Card Variant

/// Visual style variants for SCCard
public enum SCCardVariant {
    /// Default card with subtle background
    case `default`
    /// Outlined card with border, no fill
    case outline
    /// Elevated card with shadow
    case elevated
    /// Filled card with solid background
    case filled
}

// MARK: - Card

/// A versatile container component for grouping related content
public struct SCCard<Content: View>: View {
    private let variant: SCCardVariant
    private let padding: CGFloat?
    private let content: () -> Content

    public init(
        variant: SCCardVariant = .default,
        padding: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.variant = variant
        self.padding = padding
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(padding ?? TokenSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: TokenRadius.lg))
        .overlay(borderOverlay)
        .shadow(
            color: shadowColor,
            radius: shadowRadius,
            y: shadowY
        )
    }

    // MARK: - Styling

    private var backgroundColor: Color {
        switch variant {
        case .default:
            return TokenSurface.primary
        case .outline:
            return .clear
        case .elevated:
            return TokenSurface.primary
        case .filled:
            return TokenSurface.secondary
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch variant {
        case .outline:
            RoundedRectangle(cornerRadius: TokenRadius.lg)
                .stroke(TokenBorder.default, lineWidth: TokenBorderWidth.default)
        case .default, .elevated, .filled:
            EmptyView()
        }
    }

    private var shadowColor: Color {
        switch variant {
        case .elevated:
            return TokenShadow.md.color
        default:
            return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch variant {
        case .elevated:
            return TokenShadow.md.radius
        default:
            return 0
        }
    }

    private var shadowY: CGFloat {
        switch variant {
        case .elevated:
            return TokenShadow.md.y
        default:
            return 0
        }
    }
}

// MARK: - Card Header

/// Header section of a card containing title and optional description
public struct SCCardHeader<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: TokenSpacing.xs) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Card Title

/// Title text for a card header
public struct SCCardTitle: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(TokenFont.headline)
            .foregroundStyle(TokenText.primary)
    }
}

// MARK: - Card Description

/// Description/subtitle text for a card header
public struct SCCardDescription: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(TokenFont.subheadline)
            .foregroundStyle(TokenText.secondary)
    }
}

// MARK: - Card Content

/// Main content area of a card
public struct SCCardContent<Content: View>: View {
    private let spacing: CGFloat
    private let content: () -> Content

    public init(
        spacing: CGFloat = TokenSpacing.sm,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, TokenSpacing.md)
    }
}

// MARK: - Card Footer

/// Footer section of a card, typically for actions
public struct SCCardFooter<Content: View>: View {
    private let alignment: HorizontalAlignment
    private let content: () -> Content

    public init(
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .center))
        .padding(.top, TokenSpacing.md)
    }
}

// MARK: - Card Divider

/// A divider line for separating card sections
public struct SCCardDivider: View {
    public init() {}

    public var body: some View {
        Divider()
            .padding(.vertical, TokenSpacing.sm)
    }
}

// MARK: - Convenience Initializers

public extension SCCard where Content == AnyView {
    /// Creates a simple card with title and description
    static func simple(
        title: String,
        description: String? = nil,
        variant: SCCardVariant = .default
    ) -> SCCard<AnyView> {
        SCCard(variant: variant) {
            AnyView(
                VStack(alignment: .leading, spacing: TokenSpacing.xs) {
                    SCCardTitle(title)
                    if let description = description {
                        SCCardDescription(description)
                    }
                }
            )
        }
    }
}

// MARK: - Interactive Card

/// A card that responds to taps
public struct SCCardButton<Content: View>: View {
    private let variant: SCCardVariant
    private let padding: CGFloat?
    private let action: () -> Void
    private let content: () -> Content

    @State private var isPressed = false

    public init(
        variant: SCCardVariant = .default,
        padding: CGFloat? = nil,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.variant = variant
        self.padding = padding
        self.action = action
        self.content = content
    }

    public var body: some View {
        Button(action: action) {
            SCCard(variant: variant, padding: padding) {
                content()
            }
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Card Button Style

private struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(TokenAnimation.fast, value: configuration.isPressed)
    }
}
