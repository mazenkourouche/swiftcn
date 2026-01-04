import SwiftUI

// MARK: - Input Variant

/// Visual style variants for SCInput
public enum SCInputVariant {
    /// Default input style
    case `default`
    /// Error/invalid state
    case error
}

// MARK: - Input Size

/// Size variants for SCInput
public enum SCInputSize {
    /// Small input
    case sm
    /// Default/medium input
    case `default`
    /// Large input
    case lg

    var height: CGFloat {
        switch self {
        case .sm: return 40
        case .default: return TokenHeight.input
        case .lg: return 60
        }
    }

    var font: Font {
        switch self {
        case .sm: return TokenFont.subheadline
        case .default: return TokenFont.body
        case .lg: return TokenFont.title3
        }
    }

    var iconSize: IconSize {
        switch self {
        case .sm: return .sm
        case .default: return .md
        case .lg: return .lg
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .sm: return TokenGrid.x3
        case .default: return TokenPadding.inputInternal
        case .lg: return TokenGrid.x5
        }
    }
}

// MARK: - Keyboard Type Helper

/// Common keyboard types for convenience
public enum SCKeyboardType {
    case `default`
    case email
    case phone
    case number
    case decimal
    case url
    case search

    var uiKeyboardType: UIKeyboardType {
        switch self {
        case .default: return .default
        case .email: return .emailAddress
        case .phone: return .phonePad
        case .number: return .numberPad
        case .decimal: return .decimalPad
        case .url: return .URL
        case .search: return .webSearch
        }
    }
}

// MARK: - Text Content Type Helper

/// Common text content types for autofill
public enum SCTextContentType {
    case none
    case name
    case email
    case password
    case newPassword
    case oneTimeCode
    case phone
    case address
    case creditCard

    var uiTextContentType: UITextContentType? {
        switch self {
        case .none: return nil
        case .name: return .name
        case .email: return .emailAddress
        case .password: return .password
        case .newPassword: return .newPassword
        case .oneTimeCode: return .oneTimeCode
        case .phone: return .telephoneNumber
        case .address: return .fullStreetAddress
        case .creditCard: return .creditCardNumber
        }
    }
}

// MARK: - SCInput

/// A customizable text input field with support for icons, labels, and various states
public struct SCInput: View {
    // MARK: - Properties

    @Binding private var text: String
    private let placeholder: String
    private let label: String?
    private let helperText: String?
    private let errorMessage: String?
    private let leadingIcon: AppIcon?
    private let trailingIcon: AppIcon?
    private let isSecure: Bool
    private let isDisabled: Bool
    private let variant: SCInputVariant
    private let size: SCInputSize
    private let keyboardType: SCKeyboardType
    private let textContentType: SCTextContentType
    private let autocapitalization: TextInputAutocapitalization
    private let autocorrectionDisabled: Bool
    private let submitLabel: SubmitLabel
    private let onSubmit: (() -> Void)?
    private let onTrailingIconTap: (() -> Void)?

    // MARK: - Private State

    @State private var isSecureTextHidden: Bool = true
    @FocusState private var isFocused: Bool

    // MARK: - Computed Properties

    private var currentVariant: SCInputVariant {
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

    // MARK: - Initializer

    public init(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil,
        helperText: String? = nil,
        errorMessage: String? = nil,
        leadingIcon: AppIcon? = nil,
        trailingIcon: AppIcon? = nil,
        isSecure: Bool = false,
        isDisabled: Bool = false,
        variant: SCInputVariant = .default,
        size: SCInputSize = .default,
        keyboardType: SCKeyboardType = .default,
        textContentType: SCTextContentType = .none,
        autocapitalization: TextInputAutocapitalization = .sentences,
        autocorrectionDisabled: Bool = false,
        submitLabel: SubmitLabel = .done,
        onSubmit: (() -> Void)? = nil,
        onTrailingIconTap: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.isSecure = isSecure
        self.isDisabled = isDisabled
        self.variant = variant
        self.size = size
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.autocapitalization = autocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
        self.onTrailingIconTap = onTrailingIconTap
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

            // Input field
            HStack(alignment: .center, spacing: TokenSpacing.sm) {
                // Leading icon
                if let leadingIcon = leadingIcon {
                    Icon(leadingIcon, size: size.iconSize, style: .secondary)
                }

                // Text field
                Group {
                    if isSecure && isSecureTextHidden {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(size.font)
                .foregroundStyle(isDisabled ? TokenText.tertiary : TokenText.primary)
                .focused($isFocused)
                .keyboardType(keyboardType.uiKeyboardType)
                .textContentType(textContentType.uiTextContentType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(autocorrectionDisabled)
                .submitLabel(submitLabel)
                .onSubmit {
                    onSubmit?()
                }

                // Trailing icon or secure toggle
                if isSecure {
                    Button {
                        isSecureTextHidden.toggle()
                    } label: {
                        Icon(
                            isSecureTextHidden ? .eye : .eyeSlash,
                            size: size.iconSize,
                            style: .secondary
                        )
                    }
                    .buttonStyle(.plain)
                } else if let trailingIcon = trailingIcon {
                    if let onTap = onTrailingIconTap {
                        Button(action: onTap) {
                            Icon(trailingIcon, size: size.iconSize, style: .secondary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Icon(trailingIcon, size: size.iconSize, style: .secondary)
                    }
                }

                // Clear button when text is not empty and focused
                if !text.isEmpty && isFocused && !isSecure {
                    Button {
                        text = ""
                    } label: {
                        Icon(.xmarkCircleFill, size: .sm, style: .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, size.horizontalPadding)
            .frame(height: size.height)
            .background(isDisabled ? TokenSurface.muted : TokenSurface.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: TokenRadius.input))
            .overlay(
                RoundedRectangle(cornerRadius: TokenRadius.input)
                    .stroke(borderColor, lineWidth: borderWidth)
            )

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
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

// MARK: - Convenience Initializers

public extension SCInput {
    /// Creates a standard text input
    static func standard(
        text: Binding<String>,
        placeholder: String,
        leadingIcon: AppIcon? = nil
    ) -> SCInput {
        SCInput(
            text: text,
            placeholder: placeholder,
            leadingIcon: leadingIcon
        )
    }

    /// Creates a labeled text input
    static func labeled(
        text: Binding<String>,
        label: String,
        placeholder: String = "",
        leadingIcon: AppIcon? = nil
    ) -> SCInput {
        SCInput(
            text: text,
            placeholder: placeholder,
            label: label,
            leadingIcon: leadingIcon
        )
    }

    /// Creates a secure (password) input
    static func secure(
        text: Binding<String>,
        placeholder: String = "Password",
        label: String? = nil
    ) -> SCInput {
        SCInput(
            text: text,
            placeholder: placeholder,
            label: label,
            isSecure: true,
            textContentType: .password,
            autocapitalization: .never,
            autocorrectionDisabled: true
        )
    }

    /// Creates an email input
    static func email(
        text: Binding<String>,
        label: String? = "Email",
        placeholder: String = "Enter your email"
    ) -> SCInput {
        SCInput(
            text: text,
            placeholder: placeholder,
            label: label,
            leadingIcon: .person,
            keyboardType: .email,
            textContentType: .email,
            autocapitalization: .never,
            autocorrectionDisabled: true
        )
    }

    /// Creates a phone number input
    static func phone(
        text: Binding<String>,
        label: String? = "Phone",
        placeholder: String = "Enter your phone number"
    ) -> SCInput {
        SCInput(
            text: text,
            placeholder: placeholder,
            label: label,
            keyboardType: .phone,
            textContentType: .phone
        )
    }

    /// Creates a search input
    static func search(
        text: Binding<String>,
        placeholder: String = "Search...",
        onSubmit: (() -> Void)? = nil
    ) -> SCInput {
        SCInput(
            text: text,
            placeholder: placeholder,
            leadingIcon: .search,
            keyboardType: .search,
            autocorrectionDisabled: true,
            submitLabel: .search,
            onSubmit: onSubmit
        )
    }

    /// Creates a URL input
    static func url(
        text: Binding<String>,
        label: String? = "Website",
        placeholder: String = "https://example.com"
    ) -> SCInput {
        SCInput(
            text: text,
            placeholder: placeholder,
            label: label,
            keyboardType: .url,
            textContentType: .none,
            autocapitalization: .never,
            autocorrectionDisabled: true
        )
    }

    /// Creates a one-time code input
    static func oneTimeCode(
        text: Binding<String>,
        label: String? = "Verification Code",
        placeholder: String = "Enter code"
    ) -> SCInput {
        SCInput(
            text: text,
            placeholder: placeholder,
            label: label,
            keyboardType: .number,
            textContentType: .oneTimeCode,
            autocapitalization: .never,
            autocorrectionDisabled: true
        )
    }

    /// Creates a numeric input
    static func number(
        text: Binding<String>,
        label: String? = nil,
        placeholder: String = "0"
    ) -> SCInput {
        SCInput(
            text: text,
            placeholder: placeholder,
            label: label,
            keyboardType: .number
        )
    }

    /// Creates a decimal input
    static func decimal(
        text: Binding<String>,
        label: String? = nil,
        placeholder: String = "0.00"
    ) -> SCInput {
        SCInput(
            text: text,
            placeholder: placeholder,
            label: label,
            keyboardType: .decimal
        )
    }
}
