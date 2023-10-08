//
//  TextFieldRow.swift
//  Fastlane-UI
//
//  Created by softwave on 08/10/23.
//

import SwiftUI

struct TextFieldRow: View {
    
    @State private var text = ""
    
    @State private var isEnabled = true
    
    let isEnableButtonHidden: Bool
    @Binding var model: Model
    
    let ereaseAction: () -> ()
    let commitAction: () -> ()
    
    var body: some View {
        HStack {
            TextField("",
                      text: $text)
            .textFieldStyle(.squareBorder)
            
            Button(action: ereaseAction,
                   label: {
                Image(systemName: "minus.circle")
            })
            
            if !isEnableButtonHidden {
                Button {
                    isEnabled.toggle()
                } label: {
                    Image(systemName: isEnabled ? "checkmark" : "xmark" )
                }
            }
        }
        .onAppear {
            text = model.text
            isEnabled = model.enable
        }
        .onChange(of: text) { newValue in
            model.text = newValue
            commitAction()
        }
        .onChange(of: isEnabled) { newValue in
            model.enable = newValue
            commitAction()
        }
    }
}

extension TextFieldRow {
    class Model {
        
        let uid = UUID().uuidString
        
        var text: String
        
        var enable: Bool
        
        init(text: String, enable: Bool = true) {
            self.text = text
            self.enable = enable
        }
        
        init() {
            self.text = ""
            self.enable = true
        }
    }
}

extension TextFieldRow.Model: Equatable {
    static func == (lhs: TextFieldRow.Model, rhs: TextFieldRow.Model) -> Bool {
        lhs.uid == rhs.uid
    }
}
