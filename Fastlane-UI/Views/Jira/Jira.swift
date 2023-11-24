//
//  Jira.swift
//  Fastlane-UI
//
//  Created by softwave on 18/09/23.
//

import SwiftUI

struct Jira: View {
    
    var body: some View {
        VStack {
            List {
                Section("Tickets status managment") {
                    TiketsStatus()
                }
                Section("Release notes") {
                    RelaseNotes()
                }
            }
        }
    }
}
