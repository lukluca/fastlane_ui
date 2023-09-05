//
//  DeployApp.swift
//  Fastlane-UI
//
//  Created by softwave on 04/09/23.
//

import SwiftUI

private let defaultBranchName = "develop"

struct DeployApp: View {
    
    private let userDefault = UserDefaults.standard
    
    let pub = NotificationCenter.default
        .publisher(for: Process.didTerminateNotification)
    
    @State private(set) var shell: Shell = .zsh
    
    @State private var projectFolder = ""
    @State private var credentialsFolder = ""
    @State private var versionNumber = ""
    @State private var buildNumber = ""
    @State private var branchName = defaultBranchName
    @State private var releaseNotes = ""
    @State private var pushOnGit = true
    @State private var uploadToFirebase = true
    @State private var useSlack = true
    @State private var makeReleaseNotesFromJira = true
    @State private var selectedEnvironment: Environment = .test
    
    @State private var result = ""
    
    @State private var fastlaneCommand = ""
    
    var body: some View {
        VStack(spacing: 30) {
            
            SettingsButton()
            
            VStack(spacing: 10) {
                ProjectFolderView(projectFolder: $projectFolder)
                
                JiraCredentialsFoldetView(credentialsFolder: $credentialsFolder)
                
                EnvPicker(selectedEnvironment: $selectedEnvironment)
                
                VersionNumberView(versionNumber: $versionNumber)
                
                HStack {
                    Text("Build number: ")
                    TextField("Enter your build number", text: $buildNumber)
                }
                
                HStack {
                    Text("Branch name: ")
                    TextField("Enter your branch name", text: $branchName)
                }
                
                HStack {
                    Text("Release notes: ")
                    TextField("Enter your release notes (optional)", text: $releaseNotes)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                
                Toggle(" Push on Git", isOn: $pushOnGit)
                Toggle(" Upload to Firebase", isOn: $uploadToFirebase)
                Toggle(" Use Slack", isOn: $useSlack)
                Toggle(" Make relese notes from Jira", isOn: $makeReleaseNotesFromJira)
            }
            
            VStack(spacing: 10) {
                Button("Deploy app") {
                    result = execute()
                }
                .disabled(projectFolder.isEmpty ||
                          versionNumber.isEmpty ||
                          (!makeReleaseNotesFromJira && credentialsFolder.isEmpty) ||
                          buildNumber.isEmpty ||
                          branchName.isEmpty)
                Button("Show fastlane command") {
                    fastlaneCommand = makeFastlaneCommand()
                }
                .disabled(versionNumber.isEmpty ||
                          buildNumber.isEmpty ||
                          branchName.isEmpty)
            }
            
            FastlaneCommandView(command: $fastlaneCommand)
            
            Text(result)
        }
        .onAppear {
            shell = userDefault.shell ?? .zsh
            buildNumber = userDefault.buildNumber ?? ""
            branchName = userDefault.branchName ?? defaultBranchName
            pushOnGit = userDefault.pushOnGit ?? true
            uploadToFirebase = userDefault.uploadToFirebase ?? true
            useSlack = userDefault.useSlack ?? true
            makeReleaseNotesFromJira = userDefault.makeReleaseNotesFromJira ?? true
        }
        .onReceive(pub) { output in
            print(output)
        }
        .onChange(of: selectedEnvironment) { newValue in
            updateFastlaneCommand()
        }
        .onChange(of: versionNumber) { newValue in
            
            if newValue.isEmpty {
                fastlaneCommand = ""
            }
            
            updateFastlaneCommand()
        }
        .onChange(of: buildNumber) { newValue in
            userDefault.buildNumber = newValue
            
            if newValue.isEmpty {
                fastlaneCommand = ""
            }
            
            updateFastlaneCommand()
        }
        .onChange(of: branchName) { newValue in
            userDefault.branchName = newValue
            
            if newValue.isEmpty {
                fastlaneCommand = ""
            }
            
            updateFastlaneCommand()
        }
        .onChange(of: releaseNotes) { newValue in
            updateFastlaneCommand()
        }
        .onChange(of: pushOnGit) { newValue in
            userDefault.pushOnGit = newValue
            
            updateFastlaneCommand()
        }
        .onChange(of: uploadToFirebase) { newValue in
            userDefault.uploadToFirebase = newValue
            
            updateFastlaneCommand()
        }
        .onChange(of: useSlack) { newValue in
            userDefault.useSlack = newValue
            
            updateFastlaneCommand()
        }
        .onChange(of: makeReleaseNotesFromJira) { newValue in
            userDefault.makeReleaseNotesFromJira = newValue
            
            updateFastlaneCommand()
        }
        .padding()
    }
}

extension DeployApp {
    
    struct EnvPicker: View {
        
        let userDefault = UserDefaults.standard
        
        @Binding var selectedEnvironment: Environment
        
        var body: some View {
            Picker("Environment:", selection: $selectedEnvironment) {
                ForEach(Environment.allCases) { environment in
                    Text(environment.rawValue).tag(environment)
                }
            }
            .onChange(of: selectedEnvironment) { newValue in
                userDefault.environment = newValue
            }
            .onAppear {
                selectedEnvironment = userDefault.environment ?? .test
            }
        }
    }
}

extension DeployApp: FastlaneWorkflow {}

private extension DeployApp {
    
    var fastlaneArguments: FastlaneDeployArguments {
        FastlaneDeployArguments(
            environment: selectedEnvironment,
            versionNumber: versionNumber,
            buildNumber: buildNumber,
            branchName: branchName,
            releaseNotes: releaseNotes,
            pushOnGit: pushOnGit,
            uploadToFirebase: uploadToFirebase,
            useSlack: useSlack,
            makeReleaseNotesFromJira: makeReleaseNotesFromJira
        )
    }
    
    func execute() -> String {
        
        let commands: [String]
        if makeReleaseNotesFromJira {
            commands = [shell.cd(folder: projectFolder),
                        cpCredentials(credentialsFolder: credentialsFolder,
                                      projectFolder: projectFolder),
                        makeFastlaneCommand(),
                        gitRestore()]
        } else {
            commands = [shell.cd(folder: projectFolder),
                        makeFastlaneCommand()]
        }
        
        return runBundleScript(with: commands)
    }
    
    func makeFastlaneCommand() -> String {
        FastlaneCommand.deploy.fullCommand(with: fastlaneArguments)
    }
    
    func updateFastlaneCommand() {
        if !fastlaneCommand.isEmpty {
            fastlaneCommand = ""
            fastlaneCommand = makeFastlaneCommand()
        }
    }
}

enum Environment: String, CaseIterable, Identifiable {
    case test = "TEST"
    case quality = "QUALITY"
    case qualityCRM = "QUALITYCRM"
    case production = "PRODUCTION"
    
    var id: Environment { self }
}

struct BuildApp_Previews: PreviewProvider {
    static var previews: some View {
        DeployApp()
    }
}
