//
//  authAPIs.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/06/1447 AH.
//
//import Combine
import Foundation

func login(email: String, password: String) async throws -> String?{
    let newUser = User(email: email, password: try encryptPasswordLikeCryptoJS(password))
    let requestBodyEncoded = try JSONEncoder().encode(newUser)
    let urlRequest = getURLRequest(url: "http://127.0.0.1:8080/auth/login", httpMethod: "POST", headers: ["Content-Type": "application/json" ], body: requestBodyEncoded)

    let (data, response) = try await URLSession.shared.data(for: urlRequest)

    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        return nil
    }

    guard let result = try? JSONDecoder().decode(LoginBody.self, from: data) else {
        return nil
    }
    
    return result.token

}

func register(email: String, password: String) async throws -> String? {
    let newUser = User(email: email, password: try encryptPasswordLikeCryptoJS(password))
    let requestBodyEncoded = try JSONEncoder().encode(newUser)
    let urlRequest = getURLRequest(url: "http://127.0.0.1:8080/auth/signUp", httpMethod: "POST", headers: ["Content-Type": "application/json" ], body: requestBodyEncoded)

    let (_, response) = try await URLSession.shared.data(for: urlRequest)

    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        return nil
    }
    
    return try await login(email: email, password: password)

}


