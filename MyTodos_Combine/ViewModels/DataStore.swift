//
//  DataStore.swift
//  MyTodos_Combine
//
//  Created by Sergey Basin on 05.06.2021.
//

import Foundation

class DataStore: ObservableObject {
    @Published var toDos: [Todo] = []
    @Published var appError: ErrorType? = nil
    
    init() {
        if FileManager().docExist(named: fileName) {
            loadToDos()
        }
    }
    
    func addToDo(_ toDo: Todo) {
        toDos.append(toDo)
        saveToDos()
    }
    
    func updateToDo(_ toDo: Todo) {
        guard let index = toDos.firstIndex(where: {$0.id == toDo.id}) else {return}
        toDos[index] = toDo
        saveToDos()
    }
    
    func deleteToDo(at index: IndexSet) {
        toDos.remove(atOffsets: index)
        saveToDos()
    }
    
    func loadToDos() {
        FileManager().readDocument(docName: fileName) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    toDos = try decoder.decode([Todo].self, from: data)
                } catch {
                    appError = ErrorType(error: .decodingError)
                }
            case .failure(let error):
                appError = ErrorType(error: error)
            }
        }
    }
    
    func saveToDos() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(toDos)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().saveDocument(contents: jsonString, docName: fileName) { (error) in
                if let error = error {
                    appError = ErrorType(error: error)
                }
            }
        } catch {
            appError = ErrorType(error: .encodingError)
        }
    }
}
