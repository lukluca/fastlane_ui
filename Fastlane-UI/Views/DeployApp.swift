//
//  DeployApp.swift
//  Fastlane-UI
//
//  Created by softwave on 04/09/23.
//

import SwiftUI

struct DeployApp: View {
    
    let shell = Defaults.shared.shell
    
    @Default(\.xcode) private var selectedXcode: String
    @State private var selectedXcodeVersion = ""
    @Default(\.scheme) private var selectedScheme: String
    
    @Default(\.versionNumber) private var versionNumber: String
    @Default(\.buildNumber) private var buildNumber: Int

    @Default(\.useGit) private var useGit: Bool
    @Default(\.branchName) private var branchName: String
    @Default(\.pushOnGit) private var pushOnGit: Bool
    @Default(\.useGitFlow) private var useGitFlow: Bool
    
    @Default(\.useBitbucket) private var useBitbucket: Bool
    
    @Default(\.useFirebase) private var useFirebase: Bool
    @Default(\.uploadToFirebase) private var uploadToFirebase: Bool
    @Default(\.useCrashlytics) private var useCrashlytics: Bool
    @Default(\.testers) private var testers: String
    @State private var releaseNotes = ""
    
    @Default(\.useDynatrace) private var useDynatrace: Bool
    @Default(\.uploadDsymToDynatrace) private var uploadDsymToDynatrace: Bool
    
    @Default(\.useJira) private var useJira: Bool
    @Default(\.makeReleaseNotesFromJira) private var makeReleaseNotesFromJira: Bool
    @Default(\.makeJiraRelease) private var makeJiraRelease: Bool
    @Default(\.debugMode) private var debugMode: Bool
    
    @Default(\.useSlack) private var useSlack: Bool
    @Default(\.notifySlack) private var notifySlack: Bool
    
    @State private var result = ""
    
    @State private var fastlaneCommand = ""
    
    @State private var disableDeploy: Bool = false
    
    @State private var gitBranches = GitBranches().values
    
    private let schemes = Schemes().values
    
    private let xcodes = XcodeVersions().values
    
    private var xcodeVersions: [String] {
        xcodes.map { $0.1 }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 10) {
                
                if !selectedXcodeVersion.isEmpty {
                    XcodePicker(selected: $selectedXcodeVersion, xcodes: xcodeVersions)
                }
                
                SchemePicker(selectedScheme: $selectedScheme, schemes: schemes)
                
                VersionNumberView(versionNumber: $versionNumber)
                
                HStack {
                    Text("Build number: ")
                    TextField("Enter your build number",
                              value: $buildNumber,
                              formatter: NumberFormatter())
                    
                    Button(systemImage: "plus.circle.fill") {
                        buildNumber += 1
                    }
                }
                
                if useGit {
                    GitPicker(selectedBranch: $branchName, branches: gitBranches) {
                        gitBranches = GitBranches().values
                    }
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
                    Toggle(" Use GitFlow", isOn: $useGitFlow)
                }
                if useFirebase {
                    Toggle(" Upload to Firebase", isOn: $uploadToFirebase)
                    if uploadToFirebase {
                        Toggle(" Use Crashlytics", isOn: $useCrashlytics)
                    }
                }
                
                if useDynatrace {
                    Toggle(" Upload dsym to Dynatrace", isOn: $uploadDsymToDynatrace)
                }
                
                if useSlack {
                    Toggle(" Notify Slack", isOn: $notifySlack)
                }
                
                if useJira {
                    if useFirebase && uploadToFirebase {
                        Toggle(" Make release notes from Jira", isOn: $makeReleaseNotesFromJira)
                    }
                    Toggle(" Make Jira release", isOn: $makeJiraRelease)
                }
               
                Toggle(" Enable debug mode", isOn: $debugMode)
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
            if selectedXcode.isEmpty || selectedXcodeVersion.isEmpty {
                let xcode = xcodes.first
                selectedXcode = xcode?.0 ?? ""
                selectedXcodeVersion = xcode?.1 ?? ""
            }
        }
        .onChange(of: selectedScheme) { _ in
            updateFastlaneCommand()
        }
        .onChange(of: selectedXcode) { _ in
            updateFastlaneCommand()
        }
        .onChange(of: selectedXcodeVersion) { newValue in
            selectedXcode = xcodes.first { (path, version) in
               version == newValue
            }?.0 ?? ""
            
        }
        .onChange(of: versionNumber) { newValue in
            if newValue.isEmpty {
                fastlaneCommand = ""
            }
            
            update()
        }
        .onChange(of: buildNumber) { _ in
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
        .onChange(of: useGitFlow) { _ in
            update()
        }
        .onChange(of: uploadToFirebase) { _ in
            update()
        }
        .onChange(of: useCrashlytics) { _ in
            update()
        }
        .onChange(of: uploadDsymToDynatrace) { _ in
            update()
        }
        .onChange(of: notifySlack) { _ in
            update()
        }
        .onChange(of: makeReleaseNotesFromJira) { _ in
            update()
        }
        .onChange(of: debugMode) { _ in
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
            Picker("Scheme:", selection: $selectedScheme) {
                ForEach(schemes, id: \.self) {
                    Text($0).tag($0)
                }
            }
        }
    }
    
    struct GitPicker: View {
        
        @Binding var selectedBranch: String
        
        let branches: [String]
        let action: () -> Void
        
        var body: some View {
            
            HStack {
                Picker("Git Branch:", selection: $selectedBranch) {
                    ForEach(branches, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                
                Button(systemImage: "arrow.counterclockwise", action: action)
            }
        }
    }
    
    struct XcodePicker: View {
        
        @Binding var selected: String
        
        let xcodes: [String]
        
        var body: some View {
            
            HStack {
                Picker("Selected Xcode:", selection: $selected) {
                    ForEach(xcodes, id: \.self) {
                        Text($0).tag($0)
                    }
                }
            }
        }
    }
}

extension DeployApp: FastlaneWorkflow {}

private extension DeployApp {
    
    var fastlaneArguments: FastlaneDeployArguments {
        FastlaneDeployArguments(
            xcode: selectedXcode,
            scheme: selectedScheme,
            versionNumber: versionNumber,
            buildNumber: buildNumber,
            branchName: branchName,
            testers: testers,
            releaseNotes: releaseNotes,
            pushOnGit: pushOnGit,
            useBitbucket: useBitbucket,
            uploadToFirebase: uploadToFirebase,
            useCrashlytics: useCrashlytics,
            useDynatrace: uploadDsymToDynatrace,
            notifySlack: notifySlack,
            makeReleaseNotesFromJira: makeReleaseNotesFromJira, 
            makeJiraRelease: makeJiraRelease,
            debugMode: debugMode
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
        
        var commands = firstStep
        if useBitbucket {
            commands.append(cpCredentialsBitbucket(projectFolder: folder))
        }
        if makeReleaseNotesFromJira || makeJiraRelease {
            commands.append(cpCredentialsJira(projectFolder: folder))
        }
        
        commands.append(deploy())
            
        if useBitbucket {
            commands.append(gitRestoreBitbucket())
        }
        
        if makeReleaseNotesFromJira || makeJiraRelease {
            commands.append(gitRestoreJira())
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
            
            guard !contents.isEmpty else {
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
        }.sorted()
    }
}


private struct XcodeVersions {
    
    let values: [(String, String)]
    
    init() {
        
        func extract() -> [(String, String)] {
            
            let contents = (try? FileManager.default.contentsOfDirectory(atPath: "/Applications")) ?? []
            
            let xcodes = contents.filter {
                $0.hasPrefix("Xcode") && $0.hasSuffix(".app")
            }
            
            return xcodes.compactMap { xcode -> (String, String)? in
                
                let versionPath = "/Applications/\(xcode)/Contents/version.plist"
                
                let exists = FileManager.default.fileExists(atPath: versionPath)
                
                guard exists else {
                    return nil
                }
                
                let url = URL(fileURLWithPath: versionPath)
                guard let data = try? Data(contentsOf: url) else {
                    return nil
                }
                
                let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:String]
                
                guard let plist else { return nil }
                
                let version = plist["CFBundleShortVersionString"] ?? ""
                let build = plist["ProductBuildVersion"] ?? ""
                
                return ("/Applications/" + xcode, "Version \(version) (\(build))")
            }
        }
        
        values = extract().sorted(by: { lhs, rhs in
            lhs.1 < rhs.1
        })
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
