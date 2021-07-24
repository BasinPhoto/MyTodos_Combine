//
//  DataStore.swift
//  MyTodos_Combine
//
//  Created by Sergey Basin on 05.06.2021.
//

import Foundation
import Combine

class DataStore: ObservableObject {
    var toDos = CurrentValueSubject<[Todo], Never>([])
    var appError = CurrentValueSubject<ErrorType?, Never>(nil)
    
    var subscriptions = Set<AnyCancellable>()
    var addToDo = PassthroughSubject<Todo, Never>()
    var updateToDo = PassthroughSubject<Todo, Never>()
    var deleteToDo = PassthroughSubject<IndexSet, Never>()
    var loadToDos = Just(FileManager.docDirUrl.appendingPathComponent(fileName))
    
    init() {
        addSubscriptions()
    }
    
    func addSubscriptions() {
        appError
            .sink { _ in
                self.objectWillChange.send()
            }
            .store(in: &subscriptions)
        
        loadToDos
            .filter { FileManager.default.fileExists(atPath: $0.path) }
            .tryMap { url in
                try Data(contentsOf: url)
            }
            .decode(type: [Todo].self, decoder: JSONDecoder())
            .subscribe(on: DispatchQueue(label: "back"))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    print("Loading")
                    ToDosSubscription()
                case .failure(let error):
                    if error is ToDoError {
                        appError.send(ErrorType(error: error as! ToDoError))
                    } else {
                        appError.send(ErrorType(error: .decodingError))
                        ToDosSubscription()
                    }
                }
            } receiveValue: { (todos) in
                self.objectWillChange.send()
                self.toDos.value = todos
            }
            .store(in: &subscriptions)
        
        addToDo.sink { [unowned self] todo in
            self.objectWillChange.send()
            toDos.value.append(todo)
        }
        .store(in: &subscriptions)
        
        updateToDo.sink { [unowned self] todo in
            guard let index = toDos.value.firstIndex(where: {$0.id == todo.id}) else {return}
            self.objectWillChange.send()
            toDos.value[index] = todo
        }
        .store(in: &subscriptions)
        
        deleteToDo.sink { [unowned self] index in
            self.objectWillChange.send()
            toDos.value.remove(atOffsets: index)
        }
        .store(in: &subscriptions)
    }
    
    func ToDosSubscription() {
        toDos
            .subscribe(on: DispatchQueue(label: "back"))
            .receive(on: DispatchQueue.main)
            .encode(encoder: JSONEncoder())
            .tryMap { data in
                try data.write(to: FileManager.docDirUrl.appendingPathComponent(fileName))
            }
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    print("Saving complete")
                case .failure(let error):
                    if error is ToDoError {
                        appError.send(ErrorType(error: error as! ToDoError))
                    } else {
                        appError.send(ErrorType(error: ToDoError.encodingError))
                    }
                }
            } receiveValue: { _ in
                print("Saving file was succcessful")
            }
            .store(in: &subscriptions)

        
    }
}
