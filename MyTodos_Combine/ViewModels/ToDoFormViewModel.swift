//
//  ToDoFormViewModel.swift
//  MyTodos_Combine
//
//  Created by Sergey Basin on 05.06.2021.
//

import Foundation

class ToDoFormViewModel: ObservableObject {
    @Published var name = ""
    @Published var completed = false
    var id: String?
    
    var updating: Bool {
        id != nil
    }
    
    var isDisabled: Bool {
        name.isEmpty
    }
    
    init() {}
    
    init(_ currentToDo: Todo) {
        self.name = currentToDo.name
        self.completed = currentToDo.completed
        id = currentToDo.id
    }
}
