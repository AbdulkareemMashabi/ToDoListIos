import Foundation
import SharedModels

/// Returns the localized string for `key` in the currently selected app language,
/// falling back to English then the raw key if the translation is missing.
func localized(_ key: String) -> String {
    SharedLocalization.string(
        for: key,
        languageCode: AppLanguageManager.resolvedLanguageCode
    )
}

/// Formatted variant of `localized(_:)` using `String(format:)` with the
/// current language's locale.
func localized(_ key: String, _ arguments: CVarArg...) -> String {
    SharedLocalization.string(
        for: key,
        languageCode: AppLanguageManager.resolvedLanguageCode,
        arguments: arguments
    )
}
