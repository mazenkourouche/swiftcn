import SwiftUI

// MARK: - TextArea Variant

/// Visual style variants for SCTextArea
public enum SCTextAreaVariant {
    /// Default textarea style
    case `default`
    /// Error/invalid state
    case error
}

// MARK: - TextArea Size

/// Size variants for SCTextArea
public enum SCTextAreaSize {
    /// Small textarea
    case sm
    /// Default/medium textarea
    case `default`
    /// Large textarea
    case lg

    var minHeight: CGFloat {
        switch self {
        case .sm: return 80
        case .default: return 120
        case .lg: return 180
        }
    }

    var font: Font {
        switch self {
        case .sm: return TokenFont.subheadline
        case .default: return TokenFont.body
        case .lg: return TokenFont.body
        }
    }

    var padding: CGFloat {
        switch self {
        case .sm: return TokenGrid.x3
        case .default: return TokenPadding.inputInternal
        case .lg: return TokenGrid.x5
        }
    }
}

// MARK: - SCTextArea

/// A customizable multi-line text input field with support for labels, character counts, and validation states
public struct SCTextArea: View {
    // MARK: - Properties

    @Binding private var text: String
    private let placeholder: String
    private let label: String?
    private let helperText: String?
    private let errorMessage: String?
    private let maxLength: Int?
    private let showCharacterCount: Bool
    private let minLines: Int?
    private let maxLines: Int?
    private let minHeight: CGFloat?
    private let maxHeight: CGFloat?
    private let isDisabled: Bool
    private let variant: SCTextAreaVariant
    private let size: SCTextAreaSize
    private let autocapitalization: TextInputAutocapitalization
    private let autocorrectionDisabled: Bool

    // Approximate line height based on font
    private var lineHeight: CGFloat {
        switch size {
        case .sm: return 20
        case .default: return 22
        case .lg: return 22
        }
    }

    // MARK: - Private State

    @FocusState private var isFocused: Bool

    // MARK: - Computed Properties

    private var currentVariant: SCTextAreaVariant {
        errorMessage != nil ? .error : variant
    }

    private var borderColor: Color {
        if currentVariant == .error {
            return TokenBorder.error
        }
        return isFocused ? TokenBorder.focused : TokenBorder.default
    }

    private var borderWidth: CGFloat {
        isFocused ? TokenBorderWidth.focused : TokenBorderWidth.default
    }

    private var characterCount: Int {
        text.count
    }

    private var isOverLimit: Bool {
        if let maxLength = maxLength {
            return characterCount > maxLength
        }
        return false
    }

    private var effectiveMinHeight: CGFloat {
        if let minLines = minLines {
            return CGFloat(minLines) * lineHeight + (size.padding * 2)
        }
        return minHeight ?? size.minHeight
    }

    private var effectiveMaxHeight: CGFloat? {
        if let maxLines = maxLines {
            return CGFloat(maxLines) * lineHeight + (size.padding * 2)
        }
        return maxHeight
    }

    // MARK: - Initializer

    public init(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil,
        helperText: String? = nil,
        errorMessage: String? = nil,
        maxLength: Int? = nil,
        showCharacterCount: Bool = false,
        minLines: Int? = nil,
        maxLines: Int? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        isDisabled: Bool = false,
        variant: SCTextAreaVariant = .default,
        size: SCTextAreaSize = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        autocorrectionDisabled: Bool = false
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.maxLength = maxLength
        self.showCharacterCount = showCharacterCount || maxLength != nil
        self.minLines = minLines
        self.maxLines = maxLines
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.isDisabled = isDisabled
        self.variant = variant
        self.size = size
        self.autocapitalization = autocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: TokenSpacing.sm) {
            // Label
            if let label = label {
                Text(label)
                    .font(TokenFont.label)
                    .foregroundStyle(TokenText.primary)
            }

            // Text area with placeholder
            ZStack(alignment: .topLeading) {
                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .font(size.font)
                        .foregroundStyle(TokenText.placeholder)
                        .padding(.horizontal, size.padding)
                        .padding(.vertical, size.padding)
                }

                // Text editor
                TextEditor(text: $text)
                    .font(size.font)
                    .foregroundStyle(isDisabled ? TokenText.tertiary : TokenText.primary)
                    .padding(.horizontal, size.padding - 5) // Compensate for TextEditor internal padding
                    .padding(.vertical, size.padding - 8)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled(autocorrectionDisabled)
                    .onChange(of: text) { _, newValue in
                        // Enforce max length if set
                        if let maxLength = maxLength, newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
            }
            .frame(minHeight: effectiveMinHeight, maxHeight: effectiveMaxHeight)
            .background(isDisabled ? TokenSurface.muted : TokenSurface.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: TokenRadius.input))
            .overlay(
                RoundedRectangle(cornerRadius: TokenRadius.input)
                    .stroke(borderColor, lineWidth: borderWidth)
            )

            // Footer: helper/error text and character count
            HStack {
                // Helper text or error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(TokenFont.caption)
                        .foregroundStyle(TokenStatus.error)
                } else if let helperText = helperText {
                    Text(helperText)
                        .font(TokenFont.caption)
                        .foregroundStyle(TokenText.tertiary)
                }

                Spacer()

                // Character count
                if showCharacterCount {
                    if let maxLength = maxLength {
                        Text("\(characterCount)/\(maxLength)")
                            .font(TokenFont.caption)
                            .foregroundStyle(isOverLimit ? TokenStatus.error : TokenText.tertiary)
                    } else {
                        Text("\(characterCount)")
                            .font(TokenFont.caption)
                            .foregroundStyle(TokenText.tertiary)
                    }
                }
            }
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

// MARK: - Convenience Initializers

public extension SCTextArea {
    /// Creates a standard text area
    static func standard(
        text: Binding<String>,
        placeholder: String,
        minHeight: CGFloat? = nil
    ) -> SCTextArea {
        SCTextArea(
            text: text,
            placeholder: placeholder,
            minHeight: minHeight
        )
    }

    /// Creates a labeled text area
    static func labeled(
        text: Binding<String>,
        label: String,
        placeholder: String = "",
        minHeight: CGFloat? = nil
    ) -> SCTextArea {
        SCTextArea(
            text: text,
            placeholder: placeholder,
            label: label,
            minHeight: minHeight
        )
    }

    /// Creates a text area with character limit
    static func limited(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil,
        maxLength: Int
    ) -> SCTextArea {
        SCTextArea(
            text: text,
            placeholder: placeholder,
            label: label,
            maxLength: maxLength,
            showCharacterCount: true
        )
    }

    /// Creates a text area for notes/descriptions
    static func notes(
        text: Binding<String>,
        label: String? = "Notes",
        placeholder: String = "Add notes..."
    ) -> SCTextArea {
        SCTextArea(
            text: text,
            placeholder: placeholder,
            label: label,
            size: .default
        )
    }

    /// Creates a compact text area
    static func compact(
        text: Binding<String>,
        placeholder: String = ""
    ) -> SCTextArea {
        SCTextArea(
            text: text,
            placeholder: placeholder,
            size: .sm
        )
    }

    /// Creates a large text area for long-form content
    static func large(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil
    ) -> SCTextArea {
        SCTextArea(
            text: text,
            placeholder: placeholder,
            label: label,
            size: .lg
        )
    }

    /// Creates a text area for bio/about sections
    static func bio(
        text: Binding<String>,
        label: String? = "Bio",
        placeholder: String = "Tell us about yourself...",
        maxLength: Int = 500
    ) -> SCTextArea {
        SCTextArea(
            text: text,
            placeholder: placeholder,
            label: label,
            maxLength: maxLength,
            showCharacterCount: true
        )
    }

    /// Creates a text area for message composition
    static func message(
        text: Binding<String>,
        placeholder: String = "Type your message..."
    ) -> SCTextArea {
        SCTextArea(
            text: text,
            placeholder: placeholder,
            minHeight: 100,
            size: .default
        )
    }

    /// Creates a text area with specified number of lines
    static func lines(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil,
        minLines: Int = 3,
        maxLines: Int? = nil
    ) -> SCTextArea {
        SCTextArea(
            text: text,
            placeholder: placeholder,
            label: label,
            minLines: minLines,
            maxLines: maxLines
        )
    }
}
