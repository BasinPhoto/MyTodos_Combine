//
//  ToDoError.swift
//  MyTodos_Combine
//
//  Created by Sergey Basin on 06.06.2021.
//

import Foundation

enum ToDoError: Error, LocalizedError {
    case saveError
    case readError
    case decodingError
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .saveError:
            return NSLocalizedString("Could not save ToDos. Reinstall the app.", comment: "")
        case .readError:
            return NSLocalizedString("Could not save ToDos. Reinstall the app.", comment: "")
        case .decodingError:
            return NSLocalizedString("The problem of loading todos.", comment: "")
        case .encodingError:
            return NSLocalizedString("Could not save ToDos. Reinstall the app.", comment: "")
        }
    }
}

struct ErrorType: Identifiable {
    let id = UUID()
    let error: ToDoError
}
