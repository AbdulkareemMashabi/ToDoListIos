//
//  taskAPIs.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/11/1447 AH.
//
import FirebaseFirestore

func addTaskAPI (task: ToDoTask) async throws -> String {
    do {
        let db = Firestore.firestore()
        
        let encoder = Firestore.Encoder()
        
        var data: [String: Any] = [:]
        data["mainTask"] = try encoder.encode(task.mainTask)
        data["subTasks"] = []
        data["favorite"] = false
        
        let documentRef = try await db.collection(Storage.load(key: "token")!)    .addDocument(data: data)
        
        return documentRef.documentID
    } catch {
        throw error
    }
}

func fetchAllTasksAPI () async throws -> [ToDoTask] {
    do {
        let db = Firestore.firestore()
        
        let snapshot = try await db.collection(Storage.load(key: "token")!).getDocuments()
        
        return try snapshot.documents.map { document in
            var task = try document.data(as: ToDoTask.self)
            task.documentID = document.documentID
            return task
        }
    }
    catch {
        throw error
    }
}

func updateTaskAPI (task: ToDoTask) throws {
    do {
        let db = Firestore.firestore()

        guard let documentID = task.documentID else { return }
        try db.collection(Storage.load(key: "token")!)
            .document(documentID)
            .setData(from: task)
    }catch {
        throw error
    }
}

func deleteTaskAPI (documentID: String) throws {
    do {
        let db = Firestore.firestore()
        var deleteError: Error?

        db.collection(Storage.load(key: "token")!)
            .document(documentID)
            .delete { error in
                if let error = error {
                    deleteError = error
                }
            }
        if let deleteError {
            throw deleteError
        }
    }catch {
        throw error
    }
}
