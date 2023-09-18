//
//  JiraTools.swift
//  Fastlane-UI
//
//  Created by softwave on 18/09/23.
//

import SwiftUI

struct JiraTools: View {
    
    var body: some View {
        VStack {
            List {
                Section("Configuration") {
                   JiraConfig()
                }
                Section("Release notes") {
                   JiraRelaseNotes()
                }
                Section("Tickets status managment") {
                    JiraTiketsStatus()
                }
            }
        }
    }
}
