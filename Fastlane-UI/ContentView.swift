//
//  ContentView.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import SwiftUI

private let defaultBranchName = "develop"

struct ContentView: View {
    
    let userDefault = UserDefaults.standard
    
    @State private var filename = ""
    
    let pub = NotificationCenter.default
        .publisher(for: Process.didTerminateNotification)
    
    @State private var projectFolder = ""
    @State private var versionNumber = ""
    @State private var buildNumber = ""
    @State private var branchName = defaultBranchName
    @State private var releaseNotes = ""
    @State private var pushOnGit = true
    @State private var debug = true
    @State private var selectedEnvironment: Environment = .test
    @State private var result = ""
    
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
            
            PushOnGitRadioButton(pushOnGit: $pushOnGit)
            
            DebugRadioButton(debug: $debug)
            
            Button("Build app") {
                result = execute()
            }
            .disabled(projectFolder.isEmpty ||
                      versionNumber.isEmpty ||
                      buildNumber.isEmpty ||
                      branchName.isEmpty)
            
            //TODO open new screen with results
            Text(result)
        }
        .onAppear {
            projectFolder = userDefault.projectFolder ?? ""
            versionNumber = userDefault.versionNumber ?? ""
            buildNumber = userDefault.buildNumber ?? ""
            branchName = userDefault.branchName ?? defaultBranchName
        }
        .onReceive(pub) { output in
            print(output)
        }
        .onChange(of: filename) { newValue in
            projectFolder = newValue
        }
        .onChange(of: versionNumber) { newValue in
            userDefault.versionNumber = newValue
        }
        .onChange(of: buildNumber) { newValue in
            userDefault.buildNumber = newValue
        }
        .onChange(of: branchName) { newValue in
            userDefault.branchName = newValue
        }
        .padding()
    }
}

extension ContentView {
    
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

extension ContentView {
    struct PushOnGitRadioButton: View {
        
        let userDefault = UserDefaults.standard
        
        @Binding var pushOnGit: Bool
        
        var body: some View {
            ContentView.BooleanRadioButton(text: "Push on Git: ",
                               isYes: $pushOnGit)
            .onChange(of: pushOnGit) { newValue in
                userDefault.pushOnGit = newValue
            }
            .onAppear {
                pushOnGit = userDefault.pushOnGit ?? true
            }
        }
    }
}

extension ContentView {
    struct DebugRadioButton: View {
        
        let userDefault = UserDefaults.standard
        
        @Binding var debug: Bool
        
        var body: some View {
            ContentView.BooleanRadioButton(text: "Debug mode: ",
                               isYes: $debug)
            .onChange(of: debug) { newValue in
                userDefault.debugMode = newValue
            }
            .onAppear {
                debug = userDefault.debugMode ?? true
            }
        }
    }
}

extension ContentView {
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

private extension ContentView {
    func openFileDialog() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK {
            filename = panel.url?.relativePath ?? ""
        }
    }
    
    func execute() -> String {
        
        let bash: CommandExecuting = Bash()
        
        var results = [String]()
        
        do {
            let cdResult = try bash.cd(folder: projectFolder)
            results.append(cdResult)
            let arguments = FastlaneArguments(
                environment: selectedEnvironment,
                versionNumber: versionNumber,
                buildNumber: buildNumber,
                branchName: branchName,
                releaseNotes: releaseNotes
            )
            let fastlaneResult = try bash.fastlane(arguments: arguments)
            results.append(fastlaneResult)
            
        } catch {
            results.append(error.localizedDescription)
        }
        
        return results.joined(separator: "\n")
    }
}

enum Environment: String, CaseIterable, Identifiable {
    case test = "TEST"
    case quality = "QUALITY"
    case qualityCRM = "QUALITYCRM"
    case production = "PRODUCTION"

    var id: Environment { self }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

