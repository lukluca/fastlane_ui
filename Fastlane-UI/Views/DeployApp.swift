//
//  DeployApp.swift
//  Fastlane-UI
//
//  Created by softwave on 04/09/23.
//

import SwiftUI

struct DeployApp: View {
    
    let shell = Defaults.shared.shell
    
    @Default(\.versionNumber) private var versionNumber: String
    @Default(\.buildNumber) private var buildNumber: Int

    @Default(\.useGit) private var useGit: Bool
    @Default(\.branchName) private var branchName: String
    @Default(\.pushOnGit) private var pushOnGit: Bool
    
    @Default(\.useFirebase) private var useFirebase: Bool
    @Default(\.uploadToFirebase) private var uploadToFirebase: Bool
    @Default(\.useCrashlytics) private var useCrashlytics: Bool
    @Default(\.testers) private var testers: String
    @State private var releaseNotes = ""
    
    @Default(\.useJira) private var useJira: Bool
    
    @Default(\.useSlack) private var useSlack: Bool
    @Default(\.notifySlack) private var notifySlack: Bool
    
    @Default(\.makeReleaseNotesFromJira) private var makeReleaseNotesFromJira: Bool
    @Default(\.schema) private var selectedScheme: String
    
    @State private var result = ""
    
    @State private var fastlaneCommand = ""
    
    @State private var disableDeploy: Bool = false
    
    private let gitBranches = GitBranches().values
    private let schemes = Schemes().values
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 10) {
                
                SchemePicker(selectedScheme: $selectedScheme, schemes: schemes)
                
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
                
                if useGit {
                    GitPicker(selectedBranch: $branchName, branches: gitBranches)
                }
                
                if useFirebase && uploadToFirebase {
                    HStack {
                        Text("Testers: ")
                        TextField("Enter additional testers splited using comma and space", text: $testers)
                    }
                    
                    HStack {
                        Text("Release notes: ")
                        TextField("Enter your release notes (optional)", text: $releaseNotes)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                if useGit {
                    Toggle(" Push on Git tag and commit", isOn: $pushOnGit)
                }
                if useFirebase {
                    Toggle(" Upload to Firebase", isOn: $uploadToFirebase)
                    if uploadToFirebase {
                        Toggle(" Use Crashlytics", isOn: $useCrashlytics)
                    }
                }
                if useSlack {
                    Toggle(" Notify Slack", isOn: $notifySlack)
                }
               
                if useJira && useFirebase && uploadToFirebase {
                    Toggle(" Make relese notes from Jira", isOn: $makeReleaseNotesFromJira)
                }
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
            
            if branchName.isEmpty {
                branchName = gitBranches.first ?? ""
            }
            if selectedScheme.isEmpty {
                selectedScheme = schemes.first ?? ""
            }
        }
        .onChange(of: selectedScheme) { _ in
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
        .onChange(of: useCrashlytics) { _ in
            update()
        }
        .onChange(of: notifySlack) { _ in
            update()
        }
        .onChange(of: makeReleaseNotesFromJira) { _ in
            update()
        }
        .padding()
    }
}

extension DeployApp {
    
    struct SchemePicker: View {
        
        @Binding var selectedScheme: String
        let schemes: [String]
        
        var body: some View {
            Picker("Schema:", selection: $selectedScheme) {
                ForEach(schemes, id: \.self) {
                    Text($0).tag($0)
                }
            }
        }
    }
    
    struct GitPicker: View {
        
        @Binding var selectedBranch: String
        
        let branches: [String]
        
        var body: some View {
            Picker("Git Branch:", selection: $selectedBranch) {
                ForEach(branches, id: \.self) {
                    Text($0).tag($0)
                }
            }
        }
    }
}

extension DeployApp: FastlaneWorkflow {}

private extension DeployApp {
    
    var fastlaneArguments: FastlaneDeployArguments {
        FastlaneDeployArguments(
            scheme: selectedScheme,
            versionNumber: versionNumber,
            buildNumber: buildNumber,
            branchName: branchName,
            testers: testers,
            releaseNotes: releaseNotes,
            pushOnGit: pushOnGit,
            uploadToFirebase: uploadToFirebase, 
            useCrashlytics: useCrashlytics,
            notifySlack: notifySlack,
            makeReleaseNotesFromJira: makeReleaseNotesFromJira
        )
    }
    
    func execute() -> String {
        
        let firstStep: [String]
        
        let folder: String
        
        let defaults = Defaults.shared
        if useGit && defaults.cloneFromRemote {
            let remoteURL = defaults.remoteURL
            let lastPathComponent = (remoteURL as NSString).lastPathComponent
            let mainFolder = defaults.mainFolder
            folder = mainFolder + "/" + lastPathComponent
            firstStep = [shell.cd(folder: mainFolder),
                         shell.rm(path: lastPathComponent),
                         shell.gitClone(remoteURL: remoteURL),
                         shell.cd(folder: lastPathComponent),
                         shell.gitFetchOrigin(),
                         shell.gitSwitch(branch: branchName)]
            
        } else {
            folder = Defaults.shared.projectFolder
            firstStep = [shell.cd(folder: folder)]
        }
        
        let commands: [String]
        if makeReleaseNotesFromJira {
            commands = firstStep +
            [cpCredentials(credentialsFolder: Defaults.shared.jiraCredentialsFolder,
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
        disableDeploy = versionNumber.isEmpty ||
                        branchName.isEmpty
    }
}

private struct Schemes {
    let values: [String]
    
    init() {
        
        let path = Defaults.shared.projectFolder
        let contents = (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
        
        let proj = contents.first {
            $0.hasSuffix(".xcodeproj")
        }
        
        if let proj {
            let xcschemesPath = path + "/" + "\(proj)/xcshareddata/xcschemes"
            
            let xcschemes = (try? FileManager.default.contentsOfDirectory(atPath: xcschemesPath)) ?? []
            
            values = xcschemes.map {
                $0.replacingOccurrences(of: ".xcscheme", with: "")
            }
        } else {
            values = []
        }
    }
}

private struct GitBranches {
    
    let values: [String]
    
    init() {
        
        let path = Defaults.shared.projectFolder + "/" + gitPathComponent + "/refs/heads"
        
        func extract(at path: String) -> [String] {
            
            let contents = (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
            
            if contents.isEmpty {
                return []
            }
            
            let urls = contents.map {
                URL(fileURLWithPath: path + "/" + $0)
            }
            
            let directories = urls.filter {
                $0.isDirectory
            }
            
            let notDirectories = urls.filter {
                !$0.isDirectory
            }
            
            let others = directories.flatMap {
                extract(at: $0.path())
            }
            
            return notDirectories.map {
                $0.path()
            } + others
        }
        
        let values = extract(at: path).map {
            $0.replacingOccurrences(of: path + "/", with: "")
        }.map {
            $0.replacingOccurrences(of: "//", with: "/")
        }
        
        self.values = values.filter {
            $0 != ".DS_Store"
        }
    }
}

struct DeployApp_Previews: PreviewProvider {
    static var previews: some View {
        DeployApp()
    }
}

private extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
