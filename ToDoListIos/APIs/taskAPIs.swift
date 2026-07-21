//
//  taskAPIs.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/11/1447 AH.
//
import FirebaseFirestore

func addTaskAPI (task: ToDoTask) async throws {
    do {
        let db = Firestore.firestore()
        
        let encoder = Firestore.Encoder()
        
        var data: [String: Any] = [:]
        data["mainTask"] = try encoder.encode(task.mainTask)
        data["subTasks"] = []
        
        try await db.collection(Storage.load(key: "token")!)    .addDocument(data: data)
    } catch {
        throw error
    }
}
