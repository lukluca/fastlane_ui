//
//  DeployApp.swift
//  Fastlane-UI
//
//  Created by softwave on 04/09/23.
//

import SwiftUI

struct DeployApp: View {
    
    let shell = Defaults.shared.shell
    
    @Default(\.projectFolder) private var projectFolder: String
    @Default(\.mainFolder) private var mainFolder: String
    @Default(\.remoteURL) private var remoteURL: String
    @Default(\.jiraCredentialsFolder) private var credentialsFolder: String
    @Default(\.versionNumber) private var versionNumber: String
    @Default(\.buildNumber) private var buildNumber: Int
    @Default(\.branchName) private var branchName: String
    @State private var releaseNotes = ""
    @Default(\.pushOnGit) private var pushOnGit: Bool
    @Default(\.uploadToFirebase) private var uploadToFirebase: Bool
    @Default(\.useSlack) private var useSlack: Bool
    @Default(\.makeReleaseNotesFromJira) private var makeReleaseNotesFromJira: Bool
    @Default(\.cloneFromRemote) private var cloneFromRemote: Bool
    @Default(\.environment) private var selectedEnvironment: Environment
    
    @State private var result = ""
    
    @State private var fastlaneCommand = ""
    
    @State private var disableDeploy: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 10) {
                
                if cloneFromRemote {
                    MainFolderView(mainFolder: $mainFolder)
                    
                    HStack {
                        Text("Git remote url")
                        TextField("Enter your git remote url", text: $remoteURL)
                    }
                    
                } else {
                    ProjectFolderView(projectFolder: $projectFolder)
                }
                
                JiraCredentialsFoldetView(credentialsFolder: $credentialsFolder)
                    .hidden(makeReleaseNotesFromJira == false)
                
                EnvPicker(selectedEnvironment: $selectedEnvironment)
                
                VersionNumberView(versionNumber: $versionNumber)
                
                HStack {
                    Text("Build number: ")
                    TextField("Enter your build number",
                              value: $buildNumber,
                              formatter: NumberFormatter())
                    
                    Button {
                        buildNumber += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }

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
                Toggle(" Clone git from remote", isOn: $cloneFromRemote)
            }
            
            VStack(spacing: 10) {
                Button("Deploy app") {
                    result = execute()
                }
                .disabled(disableDeploy)
                Button("Show fastlane command") {
                    fastlaneCommand = deploy()
                }
                .disabled(versionNumber.isEmpty ||
                          branchName.isEmpty)
            }
            
            FastlaneCommandView(command: $fastlaneCommand)
            
            Text(result)
        }
        .onAppear {
            updateDeployButtonActivity()
        }
        .onChange(of: projectFolder) { _ in
            updateDeployButtonActivity()
        }
        .onChange(of: credentialsFolder) { _ in
            updateDeployButtonActivity()
        }
        .onChange(of: selectedEnvironment) { _ in
            updateFastlaneCommand()
        }
        .onChange(of: versionNumber) { newValue in
            if newValue.isEmpty {
                fastlaneCommand = ""
            }
            
            update()
        }
        .onChange(of: buildNumber) { newValue in
            update()
        }
        .onChange(of: branchName) { newValue in
            if newValue.isEmpty {
                fastlaneCommand = ""
            }
            
            update()
        }
        .onChange(of: releaseNotes) { _ in
            update()
        }
        .onChange(of: pushOnGit) { _ in
            update()
        }
        .onChange(of: uploadToFirebase) { _ in
            update()
        }
        .onChange(of: useSlack) { _ in
            update()
        }
        .onChange(of: makeReleaseNotesFromJira) { _ in
            update()
        }
        .padding()
    }
}

extension DeployApp {
    
    struct EnvPicker: View {
        
        @Binding var selectedEnvironment: Environment
        
        var body: some View {
            Picker("Environment:", selection: $selectedEnvironment) {
                ForEach(Environment.allCases) { environment in
                    Text(environment.rawValue).tag(environment)
                }
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
        
        let firstStep: [String]
        
        let folder: String
        
        if cloneFromRemote {
            let lastPathComponent = (remoteURL as NSString).lastPathComponent
            folder = mainFolder + "/" + lastPathComponent
            firstStep = [shell.cd(folder: mainFolder),
                         shell.rm(path: lastPathComponent),
                         shell.gitClone(remoteURL: remoteURL),
                         shell.cd(folder: lastPathComponent),
                         shell.gitFetchOrigin(),
                         shell.gitSwitch(branch: branchName)]
            
        } else {
            folder = projectFolder
            firstStep = [shell.cd(folder: folder)]
        }
        
        let commands: [String]
        if makeReleaseNotesFromJira {
            commands = firstStep +
                        [cpCredentials(credentialsFolder: credentialsFolder,
                                       projectFolder: folder),
                        deploy(),
                        gitRestore()]
        } else {
            commands = firstStep +
                        [deploy()]
        }
        
        return runBundleScript(with: commands)
    }
    
    func deploy() -> String {
        FastlaneCommand.deploy.fullCommand(with: fastlaneArguments)
    }
    
    func update() {
        updateDeployButtonActivity()
        updateFastlaneCommand()
    }
    
    func updateFastlaneCommand() {
        if !fastlaneCommand.isEmpty {
            fastlaneCommand = ""
            fastlaneCommand = deploy()
        }
    }
    
    func updateDeployButtonActivity() {
        if makeReleaseNotesFromJira && credentialsFolder.isEmpty {
            disableDeploy = true
            return
        }
        
        disableDeploy = projectFolder.isEmpty ||
                            versionNumber.isEmpty ||
                            branchName.isEmpty
    }
}

enum Environment: String, CaseIterable, Identifiable {
    case test = "TEST"
    case quality = "QUALITY"
    case qualityCRM = "QUALITYCRM"
    case production = "PRODUCTION"
    
    var id: Environment { self }
}

struct DeployApp_Previews: PreviewProvider {
    static var previews: some View {
        DeployApp()
    }
}
