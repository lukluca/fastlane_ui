//
//  Tools.swift
//  Fastlane-UI
//
//  Created by softwave on 06/09/23.
//

import SwiftUI

struct Tools: View {
    
    @Default(\.shell) private var shell: Shell
    
    var body: some View {
        List {
            Section("Settings") {
                RadioButton(title: "Shell:",
                            isSelected: $shell)
            }
            Section("Fastlane") {
                EmptyView()
            }
        }
    }
}


extension Tools {
    struct RadioButton<R>: View where R: RadioButtonRepresentable,
                                        R.RawValue: Hashable,
                                        R.AllCases: RandomAccessCollection {
        
        let title: String
      
        @Binding var isSelected: R
        
        var body: some View {
            Picker(title, selection: $isSelected) {
                ForEach(R.allCases, id: \.rawValue) {
                    Text($0.title).tag($0)
                }
            }
            .pickerStyle(RadioGroupPickerStyle())
        }
    }
}

typealias RadioButtonRepresentable = CaseIterable & Hashable & RawRepresentable & TitleOwner

protocol TitleOwner {
    var title: String { get }
}
