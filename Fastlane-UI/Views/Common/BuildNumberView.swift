//
//  BuildNumberView.swift
//  Fastlane-UI
//
//  Created by softwave on 23/02/24.
//

import SwiftUI

struct BuildNumberView: View {
    
    @Binding var buildNumber: Int
    
    var body: some View {
        HStack {
            Text("Build number: ")
            TextField("Enter your build number",
                      value: $buildNumber,
                      formatter: NumberFormatter())
            
            Button(systemImage: "plus.circle.fill") {
                buildNumber += 1
            }
        }
    }
}



