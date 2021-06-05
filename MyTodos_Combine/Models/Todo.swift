//
//  Todo.swift
//  MyTodos_Combine
//
//  Created by Sergey Basin on 05.06.2021.
//

import Foundation

struct Todo: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var completed: Bool = false
    
    static var sampleData: [Todo] {
        [
            Todo(name: "Написать письмо"),
            Todo(name: "Скинуть видео на комп", completed: true)
        ]
    }
}
