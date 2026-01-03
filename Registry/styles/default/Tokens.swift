import SwiftUI

// MARK: - Primitive Colors

/// Base color palette. Users can customize these to match their brand.
public enum TokenPrimitive {
    // Neutral palette
    public static let white = Color.white
    public static let black = Color.black

    public static let gray50 = Color("Gray50")
    public static let gray100 = Color("Gray100")
    public static let gray200 = Color("Gray200")
    public static let gray300 = Color("Gray300")
    public static let gray400 = Color("Gray400")
    public static let gray500 = Color("Gray500")
    public static let gray600 = Color("Gray600")
    public static let gray700 = Color("Gray700")
    public static let gray800 = Color("Gray800")
    public static let gray900 = Color("Gray900")
    public static let gray950 = Color("Gray950")

    // Status colors
    public static let error = Color("Error")
    public static let warning = Color("Warning")
    public static let success = Color("Success")
}

// MARK: - Semantic Colors

/// Surface/background colors
public enum TokenSurface {
    public static let primary = TokenPrimitive.white
    public static let secondary = TokenPrimitive.gray100
    public static let tertiary = TokenPrimitive.gray50
    public static let muted = TokenPrimitive.gray200
    public static let inverse = TokenPrimitive.gray900
}

/// Text colors
public enum TokenText {
    public static let primary = TokenPrimitive.gray950
    public static let secondary = TokenPrimitive.gray700
    public static let tertiary = TokenPrimitive.gray500
    public static let placeholder = TokenPrimitive.gray400
    public static let inverse = TokenPrimitive.white
    public static let destructive = TokenPrimitive.error
}

/// Border colors
public enum TokenBorder {
    public static let `default` = TokenPrimitive.gray200
    public static let focused = TokenPrimitive.gray900
    public static let error = TokenPrimitive.error
}

/// Status colors
public enum TokenStatus {
    public static let error = TokenPrimitive.error
    public static let warning = TokenPrimitive.warning
    public static let success = TokenPrimitive.success
}

// MARK: - Grid System (4pt base)

public enum TokenGrid {
    public static let x1: CGFloat = 4
    public static let x2: CGFloat = 8
    public static let x3: CGFloat = 12
    public static let x4: CGFloat = 16
    public static let x5: CGFloat = 20
    public static let x6: CGFloat = 24
    public static let x8: CGFloat = 32
    public static let x10: CGFloat = 40
    public static let x12: CGFloat = 48
    public static let x14: CGFloat = 56
    public static let x16: CGFloat = 64
}

// MARK: - Spacing

public enum TokenSpacing {
    public static let none: CGFloat = 0
    public static let xs = TokenGrid.x1      // 4
    public static let sm = TokenGrid.x2      // 8
    public static let md = TokenGrid.x4      // 16
    public static let lg = TokenGrid.x6      // 24
    public static let xl = TokenGrid.x8      // 32
    public static let xxl = TokenGrid.x12    // 48
}

// MARK: - Padding

public enum TokenPadding {
    public static let screenHorizontal = TokenGrid.x5   // 20
    public static let contentVertical = TokenGrid.x4    // 16
    public static let inputInternal = TokenGrid.x4      // 16
    public static let buttonHorizontal = TokenGrid.x5   // 20
    public static let buttonVertical = TokenGrid.x4     // 16
}

// MARK: - Radius

public enum TokenRadius {
    public static let none: CGFloat = 0
    public static let sm = TokenGrid.x2      // 8
    public static let md = TokenGrid.x3      // 12
    public static let lg = TokenGrid.x4      // 16
    public static let xl = TokenGrid.x5      // 20
    public static let full: CGFloat = 9999

    // Component-specific
    public static let button = TokenGrid.x4  // 16
    public static let input = TokenGrid.x4   // 16
}

// MARK: - Heights

public enum TokenHeight {
    public static let button: CGFloat = 52
    public static let input: CGFloat = 54
}

// MARK: - Border Widths

public enum TokenBorderWidth {
    public static let `default`: CGFloat = 1.5
    public static let focused: CGFloat = 2
}

// MARK: - Typography (Dynamic Type supported)

public enum TokenFont {
    // Body styles
    public static let caption = Font.system(.caption)
    public static let footnote = Font.system(.footnote)
    public static let body = Font.system(.body)
    public static let callout = Font.system(.callout)
    public static let subheadline = Font.system(.subheadline)
    public static let headline = Font.system(.headline)

    // Title styles
    public static let title3 = Font.system(.title3)
    public static let title2 = Font.system(.title2)
    public static let title = Font.system(.title)
    public static let largeTitle = Font.system(.largeTitle)

    // Component-specific (with relative sizing for accessibility)
    public static let button = Font.system(.body, weight: .semibold)
    public static let input = Font.system(.title3)
    public static let label = Font.system(.subheadline, weight: .medium)
}

// MARK: - Shadows

public struct ShadowStyle {
    public let color: Color
    public let radius: CGFloat
    public let y: CGFloat
}

public enum TokenShadow {
    public static let sm = ShadowStyle(color: .black.opacity(0.05), radius: 2, y: 1)
    public static let md = ShadowStyle(color: .black.opacity(0.1), radius: 4, y: 2)
    public static let lg = ShadowStyle(color: .black.opacity(0.15), radius: 8, y: 4)
}

// MARK: - Animation

public enum TokenAnimation {
    public static let fast: Animation = .easeOut(duration: 0.15)
    public static let normal: Animation = .easeOut(duration: 0.25)
    public static let slow: Animation = .easeOut(duration: 0.4)
    public static let spring: Animation = .spring(response: 0.3, dampingFraction: 0.7)
}
