//
//  Models.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/06/1447 AH.
//


struct User: Codable {
    let email: String?
    let password: String?
    let deviceId: String?
}

struct LoginBody: Codable {
    let token: String
    let userId: String
}
