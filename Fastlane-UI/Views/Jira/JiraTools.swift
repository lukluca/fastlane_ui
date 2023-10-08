//
//  JiraTools.swift
//  Fastlane-UI
//
//  Created by softwave on 18/09/23.
//

import SwiftUI

struct JiraTools: View {
    
    @Default(\.projectFolder) private var projectFolder: String
    
    var body: some View {
        VStack {
            List {
                Section("Configuration") {
                    Config(projectFolder: $projectFolder)
                }
                Section("Release notes") {
                    RelaseNotes(projectFolder: $projectFolder)
                }
                Section("Tickets status managment") {
                    TiketsStatus()
                }
            }
        }
    }
}
