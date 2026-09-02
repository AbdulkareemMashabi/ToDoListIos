import Foundation
import FirebaseAuth
import FirebaseFirestore

enum APIError: Error, LocalizedError {
    case loginFailed
    case registerFailed
    case resetPasswordFailed
    case deleteAccountFailed
    case missingDeviceID
    case addTaskFailed
    case fetchTasksFailed
    case updateTaskFailed
    case deleteTaskFailed

    var errorDescription: String? {
        switch self {
        case .loginFailed:
            return localized("api.loginFailed")
        case .registerFailed:
            return localized("api.registerFailed")
        case .resetPasswordFailed:
            return localized("api.resetPasswordFailed")
        case .deleteAccountFailed:
            return localized("api.deleteAccountFailed")
        case .missingDeviceID:
            return localized("api.missingDeviceID")
        case .addTaskFailed:
            return localized("api.addTaskFailed")
        case .fetchTasksFailed:
            return localized("api.fetchTasksFailed")
        case .updateTaskFailed:
            return localized("api.updateTaskFailed")
        case .deleteTaskFailed:
            return localized("api.deleteTaskFailed")
        }
    }
}

func signUpFireBase(email: String, password: String) async throws -> String {
    do {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    } catch {
        throw APIError.registerFailed
    }
}

func loginFireBase(email: String, password: String) async throws -> String {
    do {
        let result = try await Auth.auth().signIn(
            withEmail: email,
            password: password
        )
        return result.user.uid
    } catch {
        throw APIError.loginFailed
    }
}

func resetPasswordFirebase(email: String) async throws {
    do {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    } catch {
        throw APIError.resetPasswordFailed
    }
}

func deleteAccountFirebase(email: String, password: String) async throws {
    do {
        // Ensure we have a signed-in Firebase user before touching anything.
        if Auth.auth().currentUser == nil {
            _ = try await loginFireBase(email: email, password: password)
        }
        guard let user = Auth.auth().currentUser else {
            throw APIError.deleteAccountFailed
        }

        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: password
        )
        try await user.reauthenticate(with: credential)

        let db = Firestore.firestore()
        let snapshot = try await db.collection(user.uid).getDocuments()

        let batch = db.batch()
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        try await batch.commit()

        try await user.delete()

        Storage.save(key: AppConstants.tokenKeychainKey, value: "")
    } catch {
        throw APIError.deleteAccountFailed
    }
}
