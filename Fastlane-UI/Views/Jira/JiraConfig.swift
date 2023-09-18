//
//  JiraConfig.swift
//  Fastlane-UI
//
//  Created by softwave on 18/09/23.
//

import SwiftUI

struct JiraConfig: View {
    
    @State private var rows = [JiraConfig.Row.Model]()
    
    var body: some View {
        VStack(alignment: .leading) {
            // TODO: move here folder view
            HStack {
                Text("Ticket status")
                Button {
                    rows.append(JiraConfig.Row.Model())
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            ForEach($rows, id: \.self) { row in
                Row(model: row) {
                    rows.removeAll { another in
                        another == row.wrappedValue
                    }
                }
            }
        }
    }
}

private extension JiraConfig {
    struct Row: View {
        
        @FocusState private var isTextFieldFocused: Bool
        
        @Binding var model: Model
        
        let action: () -> ()
        
        var body: some View {
            HStack {
                TextField("",
                          text: $model.text)
                .textFieldStyle(.squareBorder)
                .focused($isTextFieldFocused)
                .onChange(of: isTextFieldFocused) { isFocused in
                    if !isFocused {
                        model.save()
                    }
                }
                Button {
                    model.erase()
                    action()
                } label: {
                    Image(systemName: "minus.circle")
                }
            }
        }
    }
}


private extension JiraConfig.Row {
    class Model: ObservableObject {
        
        let uid = UUID().uuidString
        
        @Published var text: String = ""
        
        func erase() {
            text = ""
            save()
        }
        
        func save() {
            
        }
    }
}

extension JiraConfig.Row.Model: Hashable {
    static func == (lhs: JiraConfig.Row.Model, rhs: JiraConfig.Row.Model) -> Bool {
        lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(uid)
    }
}

private struct TicketStatus {
    // TODO: here save and read from file
}
