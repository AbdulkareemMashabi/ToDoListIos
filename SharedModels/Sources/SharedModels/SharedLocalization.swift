import Foundation

public enum SharedLocalization {
    /// Looks up a localized string in the bundle's `.lproj` folder for the given language,
    /// falling back to English and finally to the raw key.
    public static func string(
        for key: String,
        languageCode: String,
        bundle: Bundle = .main
    ) -> String {
        if let localized = string(for: key, languageCode: languageCode, in: bundle) {
            return localized
        }
        if languageCode != "en",
           let fallback = string(for: key, languageCode: "en", in: bundle) {
            return fallback
        }
        return key
    }

    /// Formatted variant that applies `String(format:)` with the resolved language locale.
    public static func string(
        for key: String,
        languageCode: String,
        bundle: Bundle = .main,
        arguments: [CVarArg]
    ) -> String {
        let format = string(for: key, languageCode: languageCode, bundle: bundle)
        return String(format: format, locale: Locale(identifier: languageCode), arguments: arguments)
    }

    private static func string(for key: String, languageCode: String, in bundle: Bundle) -> String? {
        guard
            let path = bundle.path(forResource: languageCode, ofType: "lproj"),
            let localizedBundle = Bundle(path: path)
        else {
            return nil
        }
        let value = NSLocalizedString(key, tableName: nil, bundle: localizedBundle, value: "\u{0}\u{0}", comment: "")
        return value == "\u{0}\u{0}" ? nil : value
    }
}
