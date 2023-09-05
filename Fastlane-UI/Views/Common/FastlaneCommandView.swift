//
//  FastlaneCommandView.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import SwiftUI

struct FastlaneCommandView: View {
    
    @Binding var command: String
    
    var body: some View {
        if !command.isEmpty {
            HStack {
                Text("Fastalane command: ")
                TextField("",
                          text: $command,
                          axis: .vertical)
            }
        }
    }
}
