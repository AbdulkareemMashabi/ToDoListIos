//
//  helpers.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 03/06/1447 AH.
//

import Foundation
import CryptoSwift

func localized(_ key: String) -> String {
    return localized(key, languageCode: AppLanguageManager.resolvedLanguageCode)
}

func localized(_ key: String, _ arguments: CVarArg...) -> String {
    let languageCode = AppLanguageManager.resolvedLanguageCode
    let format = localized(key)
    return String(format: format, locale: Locale(identifier: languageCode), arguments: arguments)
}

private func localized(_ key: String, languageCode: String) -> String {
    if let bundle = localizedBundle(for: languageCode) {
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }

    if let value = localizedStringFromCustomFolder(key, languageCode: languageCode) {
        return value
    }

    return NSLocalizedString(key, comment: "")
}

private func localizedBundle(for languageCode: String) -> Bundle? {
    guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") else {
        return nil
    }

    return Bundle(path: path)
}

private func localizedStringFromCustomFolder(_ key: String, languageCode: String) -> String? {
    guard
        let path = Bundle.main.path(forResource: languageCode, ofType: nil, inDirectory: "Localizable.strings"),
        let strings = NSDictionary(contentsOfFile: path) as? [String: String]
    else {
        return nil
    }

    return strings[key]
}

let PRIVATE_PASSWORD = "ABDULKAREEM MASHABI 1102866710"

private func evpBytesToKey(password: [UInt8], salt: [UInt8], keyLen: Int, ivLen: Int) throws -> (key: [UInt8], iv: [UInt8]) {
    precondition(salt.count == 8, "OpenSSL/CryptoJS expects 8-byte salt")

    var derived = [UInt8]()
    var prev = [UInt8]()

    while derived.count < keyLen + ivLen {
        var mdInput = prev + password + salt
        // MD5 digest of previous block + password + salt
        prev = Array(Digest.md5(mdInput))
        derived += prev
    }

    let key = Array(derived[0..<keyLen])
    let iv = Array(derived[keyLen..<(keyLen + ivLen)])
    return (key, iv)
}

/// Encrypts plaintext with a passphrase to match CryptoJS.AES.encrypt(plaintext, passphrase)
/// using OpenSSL-compatible formatting: Base64("Salted__" + salt + ciphertext)
/// - Parameters:
///   - plaintext: UTF-8 text to encrypt
///   - passphrase: passphrase string (same as PRIVATE_KEY in JS)
/// - Returns: Base64 string compatible with CryptoJS default OpenSSL formatter
func encryptWithPassphraseForCryptoJS(_ plaintext: String, passphrase: String) throws -> String {
    let salt = AES.randomIV(8)
    let (key, iv) = try evpBytesToKey(password: passphrase.bytes, salt: salt, keyLen: 32, ivLen: 16)

    let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
    let ciphertext = try aes.encrypt(plaintext.bytes)

    // OpenSSL format: "Salted__" + 8-byte salt + ciphertext, then Base64
    let finalBytes: [UInt8] = "Salted__".bytes + salt + ciphertext
    return Data(finalBytes).base64EncodedString()
}

/// Convenience wrapper that uses the global PRIVATE_PASSWORD as passphrase
func encryptPasswordLikeCryptoJS(_ plaintext: String) throws -> String {
    try encryptWithPassphraseForCryptoJS(plaintext, passphrase: PRIVATE_PASSWORD)
}

func encryptForCryptoJS(text: String) -> String? {
    // CryptoJS/OpenSSL uses a random 8-byte salt
    let salt = AES.randomIV(8)

    // OpenSSL key/iv derivation (EVP_BytesToKey)
    let keyIV = try! PKCS5.PBKDF1(
        password: PRIVATE_PASSWORD.bytes,
        salt: salt,
        variant: .md5, iterations: 1,
        keyLength: 48
    ).calculate()

    let key = Array(keyIV[0..<32])     // AES-256 key
    let iv  = Array(keyIV[32..<48])    // AES IV

    let aes = try! AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
    let encryptedBytes = try! aes.encrypt(text.bytes)

    // CryptoJS output format:
    // Base64( "Salted__" + salt + ciphertext )
    let final = "Salted__".bytes + salt + encryptedBytes
    return Data(final).base64EncodedString()
}


func isValidEmail(_ email: String) -> Bool {
    let emailRegEx =
    "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return predicate.evaluate(with: email)
}

func getEmailValidation(email:String) -> String {
    if(email.isEmpty){
        return localized("validation.emailRequired")
    }
    else if (!isValidEmail(email)){
        return localized("validation.invalidEmail")
    }
    else {
        return ""
    }
}

func getPasswordValidation(password:String) -> String {
    if (password.count < 6){
        return localized("validation.passwordLength")
    }
    else {
        return getEmptyErrorMessage(fieldName: localized("common.password"), fieldValue: password)
    }
}

func getConfirmPasswordValidation(password:String, confirmPassword:String) -> String {
    if(password != confirmPassword){
        return localized("validation.passwordsMismatch")
    }
    else {
        return getEmptyErrorMessage(fieldName: localized("common.confirmPassword"), fieldValue: confirmPassword)
    }
}

func getEmptyErrorMessage(fieldName:String, fieldValue:String) -> String {
    return fieldValue.isEmpty ? localized("validation.requiredFormat", fieldName) : ""
}

func getURLRequest(url: String, httpMethod: String, headers: [String: String]? = nil, body: Data? = nil) -> URLRequest {
    var urlRequest = URLRequest(url: URL(string: url)!)
    
    urlRequest.httpMethod = httpMethod
    
    if let headers {
        for (key, value) in headers {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
    }
    
    if let body {
        urlRequest.httpBody = body
    }
    
    return urlRequest
}

//func logIn(username user: String, password pass: String) async throws -> Token {
//    let params = [
//        "grant_type": "",
//        "username": user,
//        "password": pass
//    ]
//
//    let bodyString = params.map { "\($0.key)=\($0.value)" }
//                           .joined(separator: "&")
//
//    let bodyData = bodyString.data(using: .utf8)
//    
//    let urlRequest = getURLRequest(url: "http://localhost:8000/token", httpMethod: "POST", headers: ["accept": "application/json", "Content-Type": "application/x-www-form-urlencoded"], body: bodyData)
//    
//    let (data, response) = try await URLSession.shared.data(for: urlRequest)
//    
//    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//        self.token = nil
//        throw AppErrors.generalError
//    }
//    
//    guard let token = try? JSONDecoder().decode(Token.self, from: data) else {
//        self.token = nil
//        throw AppErrors.generalError
//    }
//    
//    self.token = token
//    saveToken(token)
//    
//    return token
//}

//func getTrips() async throws -> [Trip] {
//    let urlRequest = getURLRequest(url: "http://localhost:8000/trips", httpMethod: "GET", headers: ["accept": "application/json", "Authorization":"\(token!.tokenType) \(token!.accessToken)"])
//
//    let (data, response) = try await URLSession.shared.data(for: urlRequest)
//    
//    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//        throw AppErrors.generalError
//    }
//    
//    let decoder = JSONDecoder()
//    decoder.dateDecodingStrategy = .iso8601
//    
//    guard let trips = try? decoder.decode([Trip].self, from: data) else {
//        throw AppErrors.generalError
//    }
//    
//    return trips
//}
//
//func createTrip(with trip: TripCreate) async throws -> Trip {
//
//    let encoder = JSONEncoder()
//    encoder.dateEncodingStrategy = .iso8601
//    let requestBody = try encoder.encode(trip)
//
//    let urlRequest = getURLRequest(url: "http://localhost:8000/trips", httpMethod: "POST", headers: ["accept": "application/json", "Authorization":"\(token!.tokenType) \(token!.accessToken)", "Content-Type": "application/json"], body: requestBody)
//
//    let (data, response) = try await URLSession.shared.data(for: urlRequest)
//
//    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//        throw AppErrors.generalError
//    }
//    
//    let decoder = JSONDecoder()
//    decoder.dateDecodingStrategy = .iso8601
//
//    guard let tripData = try? decoder.decode(Trip.self, from: data) else {
//        throw AppErrors.generalError
//    }
//
//    return tripData
//}
//

//func register(username user: String, password pass: String) async throws -> Token {
//    let requestBody = ["username":user, "password":pass]
//    let requestBodyencoded = try JSONSerialization.data(withJSONObject: requestBody, options: [])
//    let urlRequest = getURLRequest(url: "http://localhost:8000/register", httpMethod: "POST", headers: ["accept": "application/json", "Content-Type": "application/json" ], body: requestBodyencoded)
//
//    let (data, response) = try await URLSession.shared.data(for: urlRequest)
//    
//    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//        self.token = nil
//        throw AppErrors.generalError
//    }
//    
//    guard let token = try? JSONDecoder().decode(Token.self, from: data) else {
//        self.token = nil
//        throw AppErrors.generalError
//    }
//    
//    self.token = token
//    saveToken(token)
//    
//    return token
//    
//}
/// Derive key and IV using OpenSSL EVP_BytesToKey compatible method (MD5)
/// This reproduces CryptoJS/OpenSSL passphrase-based AES key derivation.
/// - Parameters:
///   - password: Passphrase bytes
///   - salt: 8-byte salt
///   - keyLen: desired key length in bytes (e.g., 32 for AES-256)
///   - ivLen: desired IV length in bytes (e.g., 16 for AES-CBC)
/// - Returns: (key, iv)
/// - Throws: if salt length is invalid
//private func evpBytesToKey(password: [UInt8], salt: [UInt8], keyLen: Int, ivLen: Int) throws -> (key: [UInt8], iv: [UInt8]) {
//    precondition(salt.count == 8, "OpenSSL/CryptoJS expects 8-byte salt")
//
//    var derived = [UInt8]()
//    var prev = [UInt8]()
//
//    while derived.count < keyLen + ivLen {
//        var mdInput = prev + password + salt
//        // MD5 digest of previous block + password + salt
//        prev = Array(Digest.md5(mdInput))
//        derived += prev
//    }
//
//    let key = Array(derived[0..<keyLen])
//    let iv = Array(derived[keyLen..<(keyLen + ivLen)])
//    return (key, iv)
//}

/// Encrypts plaintext with a passphrase to match CryptoJS.AES.encrypt(plaintext, passphrase)
/// using OpenSSL-compatible formatting: Base64("Salted__" + salt + ciphertext)
/// - Parameters:
///   - plaintext: UTF-8 text to encrypt
///   - passphrase: passphrase string (same as PRIVATE_KEY in JS)
/// - Returns: Base64 string compatible with CryptoJS default OpenSSL formatter
//func encryptWithPassphraseForCryptoJS(_ plaintext: String, passphrase: String) throws -> String {
//    let salt = AES.randomIV(8)
//    let (key, iv) = try evpBytesToKey(password: passphrase.bytes, salt: salt, keyLen: 32, ivLen: 16)
//
//    let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
//    let ciphertext = try aes.encrypt(plaintext.bytes)
//
//    // OpenSSL format: "Salted__" + 8-byte salt + ciphertext, then Base64
//    let finalBytes: [UInt8] = "Salted__".bytes + salt + ciphertext
//    return Data(finalBytes).base64EncodedString()
//}

/// Convenience wrapper that uses the global PRIVATE_PASSWORD as passphrase
//func encryptPasswordLikeCryptoJS(_ plaintext: String) throws -> String {
//    try encryptWithPassphraseForCryptoJS(plaintext, passphrase: PRIVATE_PASSWORD)
//}

