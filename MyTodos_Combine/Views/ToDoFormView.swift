//
//  ToDoFromView.swift
//  MyTodos_Combine
//
//  Created by Sergey Basin on 05.06.2021.
//

import SwiftUI

struct ToDoFormView: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var formVM: ToDoFormViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                VStack{
                    TextField("ToDo", text: $formVM.name)
                    Toggle("Completed", isOn: $formVM.completed)
                }
            }
        .navigationTitle("ToDo")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: cancelButton, trailing: updateSaveButton)
        }
    }
}

extension ToDoFormView {
    func updateToDo() {
        let toDo = Todo(id: formVM.id!, name: formVM.name, completed: formVM.completed)
        dataStore.updateToDo(toDo)
        presentationMode.wrappedValue.dismiss()
    }
    
    func addToDo() {
        let toDo = Todo(name: formVM.name)
        dataStore.addToDo(toDo)
        presentationMode.wrappedValue.dismiss()
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    var updateSaveButton: some View {
        Button(formVM.updating ? "Update" : "Save", action: formVM.updating ? updateToDo : addToDo)
            .disabled(formVM.isDisabled)
    }
}

struct ToDoFromView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoFormView(formVM: ToDoFormViewModel())
            .environmentObject(DataStore())
    }
}
