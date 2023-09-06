//
//  Tools.swift
//  Fastlane-UI
//
//  Created by softwave on 06/09/23.
//

import SwiftUI

struct Tools: View {
    
    private let userDefault = UserDefaults.standard
    
    @State private var shellSelected: Shell = defaultShell
    
    var body: some View {
        List {
            Section("Settings") {
                RadioButton(title: "Shell:",
                            isSelected: $shellSelected)
            }
            Section("Fastlane") {
                EmptyView()
            }
        }
        .onAppear {
            shellSelected = userDefault.shell ?? defaultShell
        }
        .onChange(of: shellSelected) { newValue in
            userDefault.shell = newValue
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
