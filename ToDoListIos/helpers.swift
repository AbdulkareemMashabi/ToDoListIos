//
//  helpers.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 03/06/1447 AH.
//

import Foundation
import CryptoSwift
import SwiftUI

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

func getBorderColor(date: String, status: Bool) -> String {
    guard !date.isEmpty else {
        return status ? ColorsToDo.green.color : ColorsToDo.orange.color
    }

    let days = getDateDifference(date: date)

    if days >= 0 && !status {
        return ColorsToDo.orange.color
    } else if days < 0 && !status {
        return ColorsToDo.red.color
    } else {
        return ColorsToDo.green.color
    }
}

func getDateDifference(date: String) -> Int {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"

    guard let endDate = formatter.date(from: date) else {
        return 0
    }

    let calendar = Calendar.current

    // Remove the time component from today
    let startDate = calendar.startOfDay(for: Date())

    let components = calendar.dateComponents([.day], from: startDate, to: endDate)

    return components.day ?? 0
}

// MARK: - Shared Task Loading Helper

@MainActor
func loadTasksShared(appToken: AppToken, loadingManager: LoadingManager, alertManager: AlertManager) async -> [ToDoTask] {
    do {
        let token: String = Storage.load(key: "token") ?? ""
        appToken.token = token
        guard !token.isEmpty else { return [] }

        loadingManager.isLoading.toggle()
        defer { loadingManager.isLoading.toggle() }

        let tasks = try await fetchAllTasksAPI()
        return tasks
    } catch {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        alertManager.show(message: message)
        return []
    }
}

@MainActor
func saveFavoriteTaskInStorage(_ task: ToDoTask?) {
    print("task", task)
    do {
        let shared = UserDefaults(suiteName: "group.com.abdulkareem.ToDoList.widget")
        if let task = task {
            let data = try JSONEncoder().encode(task)
            shared?.set(data, forKey: "favoriteTask")
            print("done")
        } else {
            shared?.removeObject(forKey: "favoriteTask")
        }

    } catch {
        print("error: \(error.localizedDescription)")
    }
}

