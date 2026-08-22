import SwiftUI
import WidgetKit

final class AppLanguageManager: ObservableObject {
    enum Language: String, CaseIterable {
        case system
        case english = "en"
        case arabic = "ar"

        var localeIdentifier: String {
            switch self {
            case .system:
                return AppLanguageManager.systemLanguageCode
            case .english, .arabic:
                return rawValue
            }
        }

        var layoutDirection: LayoutDirection {
            localeIdentifier == "ar" ? .rightToLeft : .leftToRight
        }
    }

    private static let storageKey = AppConstants.appLanguageDefaultsKey

    @Published private(set) var language: Language {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
            let shared = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
            shared?.set(language.rawValue, forKey: Self.storageKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    init() {
        let savedLanguage = UserDefaults.standard.string(forKey: Self.storageKey) ?? Language.system.rawValue
        language = Language(rawValue: savedLanguage) ?? .system
    }

    static var selectedLanguage: Language {
        let savedLanguage = UserDefaults.standard.string(forKey: storageKey) ?? Language.system.rawValue
        return Language(rawValue: savedLanguage) ?? .system
    }

    static var resolvedLanguageCode: String {
        selectedLanguage.localeIdentifier
    }

    static var systemLanguageCode: String {
        Locale.current.language.languageCode?.identifier == Language.arabic.rawValue ? Language.arabic.rawValue : Language.english.rawValue
    }

    var locale: Locale {
        Locale(identifier: language.localeIdentifier)
    }

    var layoutDirection: LayoutDirection {
        language.layoutDirection
    }

    func useEnglish() {
        language = .english
    }

    func useArabic() {
        language = .arabic
    }
}
