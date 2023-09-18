//
//  VersionNumberView.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import SwiftUI

struct VersionNumberView: View {
    
    @Binding var versionNumber: String
    
    var body: some View {
        HStack {
            Text("Version number: ")
            TextField("Enter your version number",
                      text: $versionNumber)
                .textFieldStyle(.squareBorder)
        }
    }
}
