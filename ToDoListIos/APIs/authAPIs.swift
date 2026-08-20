//
//  authAPIs.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/06/1447 AH.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthAPIError: Error, LocalizedError {
    case missingDeviceID

    var errorDescription: String? {
        switch self {
        case .missingDeviceID:
            return localized("api.missingDeviceID")
        }
    }
}

func signUpFireBase(email: String, password: String) async throws -> String {
    do {
       let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }catch {
        throw error
    }

}

func loginFireBase(email: String, password: String) async throws -> String {
    do {
       let result = try await Auth.auth().signIn(
        withEmail: email,
        password: password
    )
        return result.user.uid
    }catch {
        throw error
    }

}

func resetPasswordFirebase(email: String) async throws {
    do {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }catch {
        throw error
    }
}

func deleteAccountFirebase(email: String, password: String) async throws {
    do {
        let user = Auth.auth().currentUser
        let userId: String

        if let uid = user?.uid {
            userId = uid
        } else {
            userId = try await loginFireBase(email: email, password: password)
        }
        
        let db = Firestore.firestore()
        
        let snapshot = try await db.collection(userId).getDocuments()

        let batch = db.batch()

        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }

        try await batch.commit()
        
        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: password
        )
        
        Storage.save(key: "token", value: "")
        if let validuser = user {
            try await validuser.reauthenticate(with: credential)
            try await validuser.delete()
        }
    }catch {
        throw error
    }
}

