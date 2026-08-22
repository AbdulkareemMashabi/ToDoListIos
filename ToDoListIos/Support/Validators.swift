import Foundation

/// User-input validators. Each `check` method returns a user-facing error
/// message, or an empty string when the value is valid.
enum Validators {
    private static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    private static let minPasswordLength = 6

    static func isValidEmail(_ email: String) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    static func email(_ email: String) -> String {
        if email.isEmpty { return localized("validation.emailRequired") }
        if !isValidEmail(email) { return localized("validation.invalidEmail") }
        return ""
    }

    static func password(_ password: String) -> String {
        if password.count < minPasswordLength {
            return localized("validation.passwordLength")
        }
        return required(fieldName: localized("common.password"), value: password)
    }

    static func confirmPassword(_ password: String, _ confirmPassword: String) -> String {
        if password != confirmPassword {
            return localized("validation.passwordsMismatch")
        }
        return required(fieldName: localized("common.confirmPassword"), value: confirmPassword)
    }

    static func required(fieldName: String, value: String) -> String {
        value.isEmpty ? localized("validation.requiredFormat", fieldName) : ""
    }
}
