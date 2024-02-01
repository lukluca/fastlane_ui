//
//  JiraRelaseNotes.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import SwiftUI

extension Jira {
    struct RelaseNotes: View {
        
        let shell = Defaults.shared.shell
        
        let projectFolder = Defaults.shared.projectFolder
       
        @Default(\.jiraCredentialsFolder) private var credentialsFolder: String
        @Default(\.versionNumber) private var versionNumber: String
        
        @State private var result = ""
        @State private var fastlaneCommand = ""
        
        var body: some View {
            
            VStack(spacing: 30) {
                
                VStack(spacing: 10) {
                    JiraCredentialsFoldetView(credentialsFolder: $credentialsFolder)
                    
                    VersionNumberView(versionNumber: $versionNumber)
                }
                
                VStack(spacing: 10) {
                    Button("Copy credentials") {
                        result = executeCopyCredentials()
                    }
                    .disabled(projectFolder.isEmpty ||
                              credentialsFolder.isEmpty)
                    
                    Button("Reset credentials") {
                        result = executeResetCredentials()
                    }
                    .disabled(projectFolder.isEmpty ||
                              credentialsFolder.isEmpty)
                    
                    Button("Make relese notes") {
                        result = execute()
                    }
                    .disabled(projectFolder.isEmpty ||
                              credentialsFolder.isEmpty ||
                              versionNumber.isEmpty)
                    
                    Button("Show fastlane command") {
                        fastlaneCommand = makeFastlaneCommand()
                    }
                    .disabled(versionNumber.isEmpty)
                }
                
                FastlaneCommandView(command: $fastlaneCommand)
                
                Text(result)
            }
            .onChange(of: versionNumber) { newValue in
                
                if newValue.isEmpty {
                    fastlaneCommand = ""
                }
                
                updateFastlaneCommand()
            }
            .padding()
        }
    }
}


extension Jira.RelaseNotes: FastlaneWorkflow {}

private extension Jira.RelaseNotes {
    
    var fastlaneArguments: FastlaneGetJiraReleaseNotesArguments {
        FastlaneGetJiraReleaseNotesArguments(versionNumber: versionNumber)
    }
    
    func executeCopyCredentials() -> String {
        let shell: Shell = .bash
    
        do {
            return try shell.runCP(from: credentialsFolder + "/credentials",
                                    to: projectFolder + "/" + jiraPathComponent)
        } catch {
            return error.localizedDescription
        }
    }
    
    func executeResetCredentials() -> String {
    
        let commands = [cdProjectFolder(), gitRestoreJira()]
    
        return runBundleScript(with: commands)
    }
    
    func cdProjectFolder() -> String {
        shell.cd(folder: projectFolder)
    }
    
    func execute() -> String {
        let commands = [cdProjectFolder(),
                        cpCredentialsJira(credentialsFolder: credentialsFolder,
                                          projectFolder: projectFolder),
                        makeFastlaneCommand(),
                        gitRestoreJira()]
        
        return runBundleScript(with: commands)
    }
    
    func makeFastlaneCommand() -> String {
        FastlaneCommand.getJiraReleaseNotes.fullCommand(with: fastlaneArguments)
    }
    
    func updateFastlaneCommand() {
        if !fastlaneCommand.isEmpty {
            fastlaneCommand = ""
            fastlaneCommand = makeFastlaneCommand()
        }
    }
}
