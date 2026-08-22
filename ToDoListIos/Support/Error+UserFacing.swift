import Foundation

extension Error {
    /// Returns a message suitable for showing in a user-facing alert.
    /// Prefers a `LocalizedError.errorDescription` when available.
    var userFacingMessage: String {
        (self as? LocalizedError)?.errorDescription ?? localizedDescription
    }
}
