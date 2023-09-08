//
//  Tools.swift
//  Fastlane-UI
//
//  Created by softwave on 06/09/23.
//

import SwiftUI
import RadioButton

struct Tools: View {
    
    @Default(\.shell) private var shell: Shell
    
    var body: some View {
        List {
            Section("Settings") {
                RadioButton(title: "Shell:",
                            itemTitle: \.rawValue,
                            isSelected: $shell)
            }
            Section("Fastlane") {
                EmptyView()
            }
        }
    }
}
