//
//  BuildApp.swift
//  Fastlane-UI
//
//  Created by softwave on 04/09/23.
//

import SwiftUI

private let defaultBranchName = "develop"

struct BuildApp: View {
    
    let userDefault = UserDefaults.standard
    
    let pub = NotificationCenter.default
        .publisher(for: Process.didTerminateNotification)
    
    @State private var projectFolder = ""
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
        VStack(spacing: 10) {
            
            HStack {
                Text("Project folder: ")
                TextField("Enter your project folder", text: $projectFolder)
                
                Button(action: openFileDialog) {
                    Image(systemName: "folder.fill")
                }
            }
            
            EnvPicker(selectedEnvironment: $selectedEnvironment)
            
            HStack {
                Text("Version number: ")
                TextField("Enter your version number", text: $versionNumber)
            }
            
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
            
            VStack(spacing: 10) {
                PushOnGitRadioButton(value: $pushOnGit)
                
                UploadToFirebaseRadioButton(value: $uploadToFirebase)
                
                UseSlackRadioButton(value: $useSlack)
                
                MakeRelaseNotesFromJiraRadioButton(value: $makeReleaseNotesFromJira)
            }
            
            VStack(spacing: 10) {
                Button("Build app") {
                    result = execute()
                }
                .disabled(projectFolder.isEmpty ||
                          versionNumber.isEmpty ||
                          buildNumber.isEmpty ||
                          branchName.isEmpty)
                Button("Show fastlane command") {
                    fastlaneCommand = makeFastlaneCommand()
                }
                .disabled(projectFolder.isEmpty ||
                          versionNumber.isEmpty ||
                          buildNumber.isEmpty ||
                          branchName.isEmpty)
            }
            
            if !fastlaneCommand.isEmpty {
                HStack {
                    Text("Fastalane command: ")
                    TextField("", text: $fastlaneCommand, axis: .vertical)
                }
            }
            
            //TODO open new screen with results
            Text(result)
        }
        .onAppear {
            projectFolder = userDefault.projectFolder ?? ""
            versionNumber = userDefault.versionNumber ?? ""
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
        .onChange(of: projectFolder) { newValue in
            userDefault.projectFolder = newValue
        }
        .onChange(of: versionNumber) { newValue in
            userDefault.versionNumber = newValue
            
            updateFastlaneCommand()
        }
        .onChange(of: buildNumber) { newValue in
            userDefault.buildNumber = newValue
            
            updateFastlaneCommand()
        }
        .onChange(of: branchName) { newValue in
            userDefault.branchName = newValue
            
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

extension BuildApp {
    
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

//MARK: - Radio buttons

extension BuildApp {
    struct PushOnGitRadioButton: View {
        
        @Binding var value: Bool
        
        var body: some View {
            BuildApp.BooleanRadioButton(
                text: "Push on Git: ",
                isYes: $value)
        }
    }
}

extension BuildApp {
    struct UploadToFirebaseRadioButton: View {
        
        @Binding var value: Bool
        
        var body: some View {
            BuildApp.BooleanRadioButton(
                text: "Upload to Firebase: ",
                isYes: $value)
        }
    }
}

extension BuildApp {
    struct UseSlackRadioButton: View {
        
        @Binding var value: Bool
        
        var body: some View {
            BuildApp.BooleanRadioButton(
                text: "Use Slack: ",
                isYes: $value)
        }
    }
}

extension BuildApp {
    struct MakeRelaseNotesFromJiraRadioButton: View {
        
        @Binding var value: Bool
        
        var body: some View {
            BuildApp.BooleanRadioButton(
                text: "Make relese notes from Jira: ",
                isYes: $value)
        }
    }
}

extension BuildApp {
    struct BooleanRadioButton: View {
        
        let text: String
        @Binding var isYes: Bool
        
        var body: some View {
            Picker(text, selection: $isYes) {
                Text("Yes").tag(true)
                Text("No").tag(false)
            }
            .pickerStyle(RadioGroupPickerStyle())
        }
    }
}

private extension BuildApp {
    
    var fastlaneArguments: FastlaneArguments {
        FastlaneArguments(
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
    
    func openFileDialog() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK {
            projectFolder = panel.url?.relativePath ?? ""
        }
    }
    
    func execute() -> String {
        
        let bash: CommandExecuting = Bash()
        
        var results = [String]()
        
        do {
            let cdResult = try bash.cd(folder: projectFolder)
            results.append(cdResult)
            let fastlaneResult = try bash.fastlane(arguments: fastlaneArguments)
            results.append(fastlaneResult)
            
        } catch {
            results.append(error.localizedDescription)
        }
        
        return results.joined(separator: "\n")
    }
    
    func makeFastlaneCommand() -> String {
        bundleCommand + " " + fastlaneArguments.toArray.joined(separator: " ")
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
        BuildApp()
    }
}
