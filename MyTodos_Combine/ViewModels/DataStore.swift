//
//  DataStore.swift
//  MyTodos_Combine
//
//  Created by Sergey Basin on 05.06.2021.
//

import Foundation
import Combine

class DataStore: ObservableObject {
    @Published var toDos: [Todo] = []
    @Published var appError: ErrorType? = nil
    
    var subscriptions = Set<AnyCancellable>()
    var addToDo = PassthroughSubject<Todo, Never>()
    var updateToDo = PassthroughSubject<Todo, Never>()
    var deleteToDo = PassthroughSubject<IndexSet, Never>()
    
    init() {
        addSubscriptions()
        if FileManager().docExist(named: fileName) {
            loadToDos()
        }
    }
    
    func addSubscriptions() {
        addToDo.sink { [unowned self] todo in
            toDos.append(todo)
            saveToDos()
        }
        .store(in: &subscriptions)
        
        updateToDo.sink { [unowned self] todo in
            guard let index = toDos.firstIndex(where: {$0.id == todo.id}) else {return}
            toDos[index] = todo
            saveToDos()
        }
        .store(in: &subscriptions)
        
        deleteToDo.sink { [unowned self] index in
            toDos.remove(atOffsets: index)
            saveToDos()
        }
        .store(in: &subscriptions)
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
