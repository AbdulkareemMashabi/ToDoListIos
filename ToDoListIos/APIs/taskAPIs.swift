import FirebaseFirestore

private func userCollection() -> CollectionReference {
    let token = Storage.load(key: AppConstants.tokenKeychainKey) ?? ""
    return Firestore.firestore().collection(token)
}

func addTaskAPI(task: ToDoTask) async throws -> String {
    do {
        let encoder = Firestore.Encoder()
        let data: [String: Any] = [
            "mainTask": try encoder.encode(task.mainTask),
            "subTasks": [],
            "favorite": false
        ]
        let documentRef = try await userCollection().addDocument(data: data)
        return documentRef.documentID
    } catch {
        throw APIError.addTaskFailed
    }
}

func fetchAllTasksAPI() async throws -> [ToDoTask] {
    do {
        let snapshot = try await userCollection().getDocuments()
        return try snapshot.documents.map { document in
            var task = try document.data(as: ToDoTask.self)
            task.documentID = document.documentID
            return task
        }
    } catch {
        throw APIError.fetchTasksFailed
    }
}

@MainActor
func updateTaskAPI(task: ToDoTask) throws {
    do {
        guard let documentID = task.documentID else { return }
        try userCollection()
            .document(documentID)
            .setData(from: task)

        if task.favorite {
            saveFavoriteTaskInStorage(task)
        }
    } catch {
        throw APIError.updateTaskFailed
    }
}

func deleteTaskAPI(documentID: String) throws {
    do {
        var deleteError: Error?

        userCollection()
            .document(documentID)
            .delete { error in
                deleteError = error
            }

        if let deleteError {
            throw deleteError
        }
    } catch {
        throw APIError.deleteTaskFailed
    }
}
