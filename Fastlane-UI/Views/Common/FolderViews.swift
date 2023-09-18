//
//  FolderViews.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import SwiftUI

struct MainFolderView: View {
    
    @Binding var mainFolder: String
    
    var body: some View {
        ChooseFolderView(title: "Main folder: ",
                         placeholder: "Enter your main folder",
                         folder: $mainFolder)
    }
}

struct ProjectFolderView: View {
    
    @Binding var projectFolder: String
    
    var body: some View {
        ChooseFolderView(title: "Project folder: ",
                         placeholder: "Enter your project folder",
                         folder: $projectFolder)
    }
}

struct JiraCredentialsFoldetView: View {
    
    @Binding var credentialsFolder: String
    
    var body: some View {
        ChooseFolderView(title: "Jira credentials folder",
                         placeholder: "Enter your jira credentials folder",
                         folder: $credentialsFolder)
    }
}

struct ChooseFolderView: View {
    let title: String
    let placeholder: String
    
    @Binding var folder: String
    
    var body: some View {
        HStack {
            Text(title)
            TextField(placeholder,
                      text: $folder)
                .textFieldStyle(.squareBorder)
            
            Button(action: openFileDialog) {
                Image(systemName: "folder.fill")
            }
        }
    }
}

private extension ChooseFolderView {
    func openFileDialog() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK {
            folder = panel.url?.relativePath ?? ""
        }
    }
}
