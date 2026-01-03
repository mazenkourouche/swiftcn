import SwiftUI

// MARK: - Button Variant

/// Visual style variants for SCButton
public enum SCButtonVariant {
    /// Solid background with inverse text - primary CTA
    case `default`
    /// Border only, no fill
    case outline
    /// Muted/subtle background
    case secondary
    /// No background, appears on hover/press only
    case ghost
    /// Red/error styling for dangerous actions
    case destructive
    /// Text-only, underlined on hover - inline links
    case link

    var backgroundColor: Color {
        switch self {
        case .default:
            return TokenSurface.inverse
        case .outline:
            return .clear
        case .secondary:
            return TokenSurface.secondary
        case .ghost:
            return .clear
        case .destructive:
            return TokenStatus.error
        case .link:
            return .clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .default:
            return TokenText.inverse
        case .outline:
            return TokenText.primary
        case .secondary:
            return TokenText.primary
        case .ghost:
            return TokenText.primary
        case .destructive:
            return TokenText.inverse
        case .link:
            return TokenText.primary
        }
    }

    var borderColor: Color? {
        switch self {
        case .outline:
            return TokenBorder.default
        default:
            return nil
        }
    }

    var hasBackground: Bool {
        switch self {
        case .default, .secondary, .destructive:
            return true
        case .outline, .ghost, .link:
            return false
        }
    }
}

// MARK: - Button Size

/// Size variants for SCButton
public enum SCButtonSize {
    /// Extra small - compact UI
    case xs
    /// Small
    case sm
    /// Default/medium
    case `default`
    /// Large - prominent CTAs
    case lg
    /// Square icon button (default size)
    case icon
    /// Square icon button (xs)
    case iconXs
    /// Square icon button (sm)
    case iconSm
    /// Square icon button (lg)
    case iconLg

    var height: CGFloat {
        switch self {
        case .xs, .iconXs:
            return 32
        case .sm, .iconSm:
            return 40
        case .default, .icon:
            return 48
        case .lg, .iconLg:
            return 56
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .xs:
            return TokenGrid.x2       // 8
        case .sm:
            return TokenGrid.x3       // 12
        case .default:
            return TokenGrid.x4       // 16
        case .lg:
            return TokenGrid.x6       // 24
        case .icon, .iconXs, .iconSm, .iconLg:
            return 0
        }
    }

    var font: Font {
        switch self {
        case .xs:
            return .system(.caption, weight: .medium)
        case .sm:
            return .system(.subheadline, weight: .medium)
        case .default:
            return .system(.body, weight: .semibold)
        case .lg:
            return .system(.body, weight: .semibold)
        case .icon, .iconXs, .iconSm, .iconLg:
            return .system(.body, weight: .medium)
        }
    }

    var iconSize: IconSize {
        switch self {
        case .xs, .iconXs:
            return .sm
        case .sm, .iconSm:
            return .md
        case .default, .icon:
            return .md
        case .lg, .iconLg:
            return .lg
        }
    }

    var isIconOnly: Bool {
        switch self {
        case .icon, .iconXs, .iconSm, .iconLg:
            return true
        default:
            return false
        }
    }
}

// MARK: - SCButton

public struct SCButton<Label: View>: View {
    // MARK: - Properties

    private let action: () -> Void
    private let variant: SCButtonVariant
    private let size: SCButtonSize
    private let isLoading: Bool
    private let isDisabled: Bool
    private let isFullWidth: Bool
    private let label: () -> Label

    // MARK: - Initializer

    public init(
        variant: SCButtonVariant = .default,
        size: SCButtonSize = .default,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.isFullWidth = isFullWidth
        self.action = action
        self.label = label
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            ZStack {
                // Content (hidden when loading)
                HStack(spacing: TokenSpacing.sm) {
                    label()
                }
                .opacity(isLoading ? 0 : 1)

                // Loading indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: variant.foregroundColor))
                }
            }
            .font(size.font)
            .foregroundStyle(isDisabled ? TokenText.tertiary : variant.foregroundColor)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(width: size.isIconOnly ? size.height : nil, height: size.height)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: TokenRadius.button))
            .overlay(borderOverlay)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1)
    }

    // MARK: - Private Views

    @ViewBuilder
    private var backgroundView: some View {
        if variant.hasBackground {
            RoundedRectangle(cornerRadius: TokenRadius.button)
                .fill(isDisabled ? TokenSurface.muted : variant.backgroundColor)
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if let borderColor = variant.borderColor {
            RoundedRectangle(cornerRadius: TokenRadius.button)
                .stroke(borderColor, lineWidth: TokenBorderWidth.default)
        }
    }
}

// MARK: - Text Label Convenience Initializer

public extension SCButton where Label == Text {
    init(
        _ title: String,
        variant: SCButtonVariant = .default,
        size: SCButtonSize = .default,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            variant: variant,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            isFullWidth: isFullWidth,
            action: action
        ) {
            Text(title)
        }
    }
}

// MARK: - Text + Icon Convenience Initializer

public extension SCButton where Label == HStack<TupleView<(Icon, Text)>> {
    init(
        _ title: String,
        icon: AppIcon,
        variant: SCButtonVariant = .default,
        size: SCButtonSize = .default,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            variant: variant,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            isFullWidth: isFullWidth,
            action: action
        ) {
            HStack {
                Icon(icon, size: size.iconSize, style: .custom(variant.foregroundColor))
                Text(title)
            }
        }
    }
}

// MARK: - Icon Only Convenience Initializer

public extension SCButton where Label == Icon {
    init(
        icon: AppIcon,
        variant: SCButtonVariant = .default,
        size: SCButtonSize = .icon,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            variant: variant,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            isFullWidth: false,
            action: action
        ) {
            Icon(icon, size: size.iconSize, style: .custom(variant.foregroundColor))
        }
    }
}

// MARK: - Static Convenience Methods

public extension SCButton where Label == Text {
    static func primary(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) -> SCButton {
        SCButton(
            title,
            variant: .default,
            isLoading: isLoading,
            isDisabled: isDisabled,
            isFullWidth: isFullWidth,
            action: action
        )
    }

    static func secondary(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) -> SCButton {
        SCButton(
            title,
            variant: .secondary,
            isLoading: isLoading,
            isDisabled: isDisabled,
            isFullWidth: isFullWidth,
            action: action
        )
    }

    static func outline(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) -> SCButton {
        SCButton(
            title,
            variant: .outline,
            isLoading: isLoading,
            isDisabled: isDisabled,
            isFullWidth: isFullWidth,
            action: action
        )
    }

    static func ghost(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> SCButton {
        SCButton(
            title,
            variant: .ghost,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }

    static func destructive(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) -> SCButton {
        SCButton(
            title,
            variant: .destructive,
            isLoading: isLoading,
            isDisabled: isDisabled,
            isFullWidth: isFullWidth,
            action: action
        )
    }

    static func link(
        _ title: String,
        action: @escaping () -> Void
    ) -> SCButton {
        SCButton(
            title,
            variant: .link,
            action: action
        )
    }
}
