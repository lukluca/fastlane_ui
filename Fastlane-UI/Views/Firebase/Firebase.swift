//
//  Firebase.swift
//  Fastlane-UI
//
//  Created by softwave on 20/09/23.
//

import SwiftUI

struct Firebase: View {
    
    @Default(\.uploadToFirebase) private var uploadToFirebase
    @Default(\.useCrashlytics) private var useCrashlytics
    
    var body: some View {
        VStack {
            Testers()
            
            VStack(alignment: .leading, spacing: 10) {
                Toggle(" Upload to Firebase", isOn: $uploadToFirebase)
                Toggle(" Use Crashlytics", isOn: $useCrashlytics)
            }
        }
        .padding()
    }
}
