//
//  VersionNumberView.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import SwiftUI

struct VersionNumberView: View {
    
    private let userDefault = UserDefaults.standard
    
    @Binding var versionNumber: String
    
    var body: some View {
        HStack {
            Text("Version number: ")
            TextField("Enter your version number", text: $versionNumber)
        }
        .onAppear {
            versionNumber = userDefault.versionNumber ?? ""
        }
        .onChange(of: versionNumber) { newValue in
            userDefault.versionNumber = newValue
        }
    }
}
