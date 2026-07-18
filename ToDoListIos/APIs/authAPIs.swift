//
//  authAPIs.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/06/1447 AH.
//
//import Combine
import Foundation
import UIKit
import FirebaseAuth

enum AuthAPIError: Error, LocalizedError {
    case invalidResponseStatus(Int)
    case decodingFailed
    case missingDeviceID
    case requestConstructionFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponseStatus(let code):
            return "Request failed with status code: \(code)."
        case .decodingFailed:
            return "Failed to decode the response from the server."
        case .missingDeviceID:
            return "Unable to access a valid device identifier."
        case .requestConstructionFailed:
            return "Failed to construct a valid request."
        }
    }
}

func login(email: String, password: String) async throws -> String {
    do {
        let newUser = User(email: email, password: try encryptPasswordLikeCryptoJS(password), deviceId: nil)
        let requestBodyEncoded = try JSONEncoder().encode(newUser)
        let urlRequest = getURLRequest(url: "http://127.0.0.1:8080/auth/login", httpMethod: "POST", headers: ["Content-Type": "application/json" ], body: requestBodyEncoded)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw AuthAPIError.invalidResponseStatus(status)
        }

        guard let result = try? JSONDecoder().decode(LoginBody.self, from: data) else {
            throw AuthAPIError.decodingFailed
        }
        
        return result.token
    } catch {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        print("Login error: \(message)")
        throw error
    }
}

func register(email: String, password: String) async throws -> String {
    do {
        let newUser = User(email: email, password: try encryptPasswordLikeCryptoJS(password), deviceId: nil)
        let requestBodyEncoded = try JSONEncoder().encode(newUser)
        let urlRequest = getURLRequest(url: "http://127.0.0.1:8080/auth/signUp", httpMethod: "POST", headers: ["Content-Type": "application/json" ], body: requestBodyEncoded)

        let (_, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw AuthAPIError.invalidResponseStatus(status)
        }
        
        return try await login(email: email, password: password)
    } catch {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        print("Register error: \(message)")
        throw error
    }
}

func signUpAndLoginUsingDeviceId() async throws -> String {
    do {
        guard let deviceId = await UIDevice.current.identifierForVendor?.uuidString else {
            throw AuthAPIError.missingDeviceID
        }
        let newUser = User(email: nil, password: nil, deviceId: try encryptPasswordLikeCryptoJS(deviceId))
        let requestBodyEncoded = try JSONEncoder().encode(newUser)
        let urlRequest = getURLRequest(url: "http://127.0.0.1:8080/auth/signup-Id", httpMethod: "POST", headers: ["Content-Type": "application/json" ], body: requestBodyEncoded)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw AuthAPIError.invalidResponseStatus(status)
        }
        
        guard let result = try? JSONDecoder().decode(LoginBody.self, from: data) else {
            throw AuthAPIError.decodingFailed
        }
        
        return result.token
    } catch {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        print("SignUp with Device ID error: \(message)")
        throw error
    }
}

func resetPassword(email: String, password: String) async throws {
    do {
        guard let _ = await UIDevice.current.identifierForVendor?.uuidString else {
            throw AuthAPIError.missingDeviceID
        }
        let newUser = User(email: email, password: try encryptPasswordLikeCryptoJS(password), deviceId: nil)
        let requestBodyEncoded = try JSONEncoder().encode(newUser)
        let urlRequest = getURLRequest(url: "http://127.0.0.1:8080/auth/reset-password", httpMethod: "PUT", headers: ["Content-Type": "application/json" ], body: requestBodyEncoded)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw AuthAPIError.invalidResponseStatus(status)
        }
    } catch {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        print("Reset password error: \(message)")
        throw error
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


