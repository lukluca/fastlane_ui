//
//  JiraRelaseNotes.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import SwiftUI

struct JiraRelaseNotes: View {
    
    private let userDefault = UserDefaults.standard
    
    @State private(set) var shell: Shell = .zsh
    
    @State private var projectFolder = ""
    @State private var credentialsFolder = ""
    @State private var versionNumber = ""
    
    @State private var result = ""
    
    @State private var fastlaneCommand = ""
    
    var body: some View {
        
        VStack(spacing: 30) {
            
            SettingsButton()
            
            VStack(spacing: 10) {
                ProjectFolderView(projectFolder: $projectFolder)
                
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
        .onAppear {
            shell = userDefault.shell ?? .zsh
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

extension JiraRelaseNotes: FastlaneWorkflow {}

private extension JiraRelaseNotes {
    
    var fastlaneArguments: FastlaneGetJiraReleaseNotesArguments {
        FastlaneGetJiraReleaseNotesArguments(versionNumber: versionNumber)
    }
    
    func executeCopyCredentials() -> String {
        let shell: Shell = .bash
    
        do {
            return try shell.runCP(from: credentialsFolder + "/credentials",
                                    to: projectFolder + "/fastlane/.jira")
        } catch {
            return error.localizedDescription
        }
    }
    
    func executeResetCredentials() -> String {
    
        let commands = [cdProjectFolder(), gitRestore()]
    
        return runBundleScript(with: commands)
    }
    
    func cdProjectFolder() -> String {
        shell.cd(folder: projectFolder)
    }
    
    func execute() -> String {
        let commands = [cdProjectFolder(),
                        cpCredentials(credentialsFolder: credentialsFolder,
                                       projectFolder: projectFolder),
                        makeFastlaneCommand(),
                        gitRestore()]
        
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

protocol FastlaneWorkflow {
    var shell: Shell { get }
}

extension FastlaneWorkflow {

    func cpCredentials(credentialsFolder: String, projectFolder: String) -> String {
        shell.cp(from: credentialsFolder + "/credentials",
                 to: projectFolder + "/fastlane/.jira")
    }
    
    func runBundleScript(with commands: [String]) -> String {
        do {
            try shell.prepareBundleScript(commands: commands)
            return try shell.runBundleScript()
        } catch {
            return error.localizedDescription
        }
    }
    
    func gitRestore() -> String {
        shell.gitRestore(file: "fastlane/.jira/credentials")
    }
}
