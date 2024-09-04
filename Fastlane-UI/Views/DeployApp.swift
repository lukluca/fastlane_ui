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
    @Default(\.firstScheme) private var firstSelectedScheme: String
    @Default(\.secondScheme) private var secondSelectedScheme: String
    
    @Default(\.versionNumber) private var versionNumber: String
    @Default(\.automaticVersionNumber) private var automaticVersionNumber: Bool
    @Default(\.buildNumber) private var buildNumber: Int
    @Default(\.automaticBuildNumber) private var automaticBuildNumber: Bool
    
    private var versionNumberArg: String? {
        guard !automaticVersionNumber else {
            return nil
        }
        return versionNumber
    }
    
    private var buildNumberArg: Int? {
        guard !automaticBuildNumber else {
            return nil
        }
        return buildNumber
    }

    @Default(\.useGit) private var useGit: Bool
    @Default(\.branchName) private var branchName: String
    @Default(\.gitTag) private var gitTag: String
    @Default(\.resetGit) private var resetGit: Bool
    @Default(\.pushOnGitMessage) private var pushOnGitMessage: Bool
    @Default(\.pushOnGitTag) private var pushOnGitTag: Bool
    @Default(\.makeGitBranch) private var makeGitBranch: Bool
    
    @Default(\.makeBitbucketPr) private var makeBitbucketPr: Bool
    
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
    @Default(\.updateJiraTickets) private var updateJiraTickets: Bool
   
    @Default(\.useSlack) private var useSlack: Bool
    @Default(\.notifySlack) private var notifySlack: Bool
    
    @Default(\.openTicketServiceNow) private var openTicketServiceNow: Bool
    
    @Default(\.sendDeployEmail) private var sendDeployEmail: Bool
    
    @Default(\.uploadToAirWatch) private var uploadToAirWatch: Bool
    
    @Default(\.debugMode) private var debugMode: Bool
    
    @State private var result = ""
    
    @State private var firstSchemeFastlaneCommand = ""
    @State private var secondSchemeFastlaneCommand = ""
    
    @State private var disableDeploy: Bool = false
    
    @State private var gitBranches = GitBranches().values
    
    @State private var gitTags = GitTags().values
    
    private let schemes = Schemes().values
    
    @State private var selectedSprint: Network.Jira.Sprint = .none
    
    @Binding var sprints: Result<[Network.Jira.Sprint], Error>?
    
    private var secondSchemes: [String] {
        [noSelection] + schemes
    }
    
    private let xcodes = XcodeVersions().values
    
    private var xcodeVersions: [String] {
        xcodes.map { $0.1 }
    }
    
    private var userDefaults: [Bool] {
        [automaticVersionNumber,
         automaticBuildNumber,
         resetGit,
         pushOnGitMessage,
         pushOnGitTag,
         makeGitBranch,
         makeBitbucketPr,
         uploadToFirebase,
         uploadDsymToDynatrace,
         notifySlack,
         makeJiraRelease,
         updateJiraTickets,
         openTicketServiceNow,
         sendDeployEmail,
         uploadToAirWatch,
         debugMode
        ]
    }
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 10) {
                
                if !selectedXcodeVersion.isEmpty {
                    XcodePicker(selected: $selectedXcodeVersion, xcodes: xcodeVersions)
                }
                
                SchemePicker(selectedScheme: $firstSelectedScheme, schemes: schemes)
                
                SchemePicker(selectedScheme: $secondSelectedScheme, schemes: secondSchemes)
                
                VersionAndBuildNumberView(
                    versionNumber: $versionNumber,
                    automaticVersionNumber: $automaticVersionNumber,
                    buildNumber: $buildNumber,
                    automaticBuildNumber: $automaticBuildNumber
                )
                
                if useGit {
                    
                    GitPicker(
                        selected: $branchName,
                        title: "Git Branch:",
                        values: gitBranches) {
                            gitBranches = GitBranches().values
                        }
                    
                    GitPicker(
                        selected: $gitTag,
                        title: "Git Tag:",
                        values: gitTags) {
                            gitTags = GitTags().values
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
                
                if useJira {
                    SprintPicker(selected: $selectedSprint, result: $sprints)
                }
            }
            
            ToggleSettings(
                useGit: $useGit,
                resetGit: $resetGit,
                pushOnGitMessage: $pushOnGitMessage,
                pushOnGitTag: $pushOnGitTag,
                makeGitBranch: $makeGitBranch,
                makeBitbucketPr: $makeBitbucketPr,
                useFirebase: $useFirebase,
                uploadToFirebase: $uploadToFirebase,
                useCrashlytics: $useCrashlytics,
                useDynatrace: $useDynatrace,
                uploadDsymToDynatrace: $uploadDsymToDynatrace,
                useSlack: $useSlack,
                notifySlack: $notifySlack,
                useJira: $useJira,
                makeReleaseNotesFromJira: $makeReleaseNotesFromJira,
                makeJiraRelease: $makeJiraRelease,
                updateJiraTickets: $updateJiraTickets,
                openTicketServiceNow: $openTicketServiceNow,
                sendDeployEmail: $sendDeployEmail,
                uploadToAirWatch: $uploadToAirWatch,
                debugMode: $debugMode
            )
            
            VStack(spacing: 10) {
                Button("Deploy app") {
                    result = execute()
                }
                .disabled(disableDeploy)
                Button("Show fastlane command") {
                    firstSchemeFastlaneCommand = deployFirstScheme(
                        makeBitbucketPr: makeBitbucketPr,
                        openTicketServiceNow: openTicketServiceNow,
                        sendDeployEmail: sendDeployEmail,
                        uploadToAirWatch: uploadToAirWatch
                    )
                    secondSchemeFastlaneCommand = deploySecondScheme(
                        pushOnGitMessage: pushOnGitMessage,
                        updateJiraTickets: updateJiraTickets
                    )
                }
                .disabled(disableDeploy)
                Button("Reset to file") {
                    Defaults.shared.resetToFile()
                }
            }
            
            FastlaneCommandView(command: $firstSchemeFastlaneCommand)
            
            if secondSelectedScheme != noSelection {
                FastlaneCommandView(command: $secondSchemeFastlaneCommand)
            }
            
            Text(result)
        }
        .onAppear {
            updateDeployButtonActivity()
            
            if branchName.isEmpty && gitTag.isEmpty {
                branchName = gitBranches.first ?? ""
                gitTag = noSelection
            }
            
            if firstSelectedScheme.isEmpty && secondSelectedScheme.isEmpty {
                firstSelectedScheme = schemes.first ?? ""
                secondSelectedScheme = noSelection
            }
          
            if selectedXcode.isEmpty || selectedXcodeVersion.isEmpty {
                let xcode = xcodes.first
                selectedXcode = xcode?.0 ?? ""
                selectedXcodeVersion = xcode?.1 ?? ""
            }
        }
        .onChange(of: firstSelectedScheme) {
            updateFastlaneCommand()
        }
        .onChange(of: secondSelectedScheme) {
            updateFastlaneCommand()
        }
        .onChange(of: selectedXcode) {
            updateFastlaneCommand()
        }
        .onChange(of: selectedXcodeVersion) { _, newValue in
            selectedXcode = xcodes.first { (path, version) in
               version == newValue
            }?.0 ?? ""
            
        }
        .onChange(of: versionNumber) { _, newValue in
            if newValue.isEmpty {
                firstSchemeFastlaneCommand = ""
                secondSchemeFastlaneCommand = ""
            }
            
            update()
        }
        .onChange(of: buildNumber) {
            update()
        }
        .onChange(of: branchName) { _, newValue in
            if newValue != noSelection {
                gitTags = GitTags().values
                gitTag = noSelection
            }
            update()
        }
        .onChange(of: gitTag) { _, newValue in
            if newValue != noSelection {
                branchName = noSelection
            }
            update()
        }
        .onChange(of: userDefaults) {
            update()
        }
        .onChange(of: releaseNotes) {
            update()
        }
        .padding()
    }
}
// MARK: Toogle
extension DeployApp {
    struct ToggleSettings: View {
        
        @Binding var useGit: Bool
        @Binding var resetGit: Bool
        @Binding var pushOnGitMessage: Bool
        @Binding var pushOnGitTag: Bool
        @Binding var makeGitBranch: Bool
        @Binding var makeBitbucketPr: Bool
        @Binding var useFirebase: Bool
        @Binding var uploadToFirebase: Bool
        @Binding var useCrashlytics: Bool
        @Binding var useDynatrace: Bool
        @Binding var uploadDsymToDynatrace: Bool
        @Binding var useSlack: Bool
        @Binding var notifySlack: Bool
        @Binding var useJira: Bool
        @Binding var makeReleaseNotesFromJira: Bool
        @Binding var makeJiraRelease: Bool
        @Binding var updateJiraTickets: Bool
        @Binding var openTicketServiceNow: Bool
        @Binding var sendDeployEmail: Bool
        @Binding var uploadToAirWatch: Bool
        @Binding var debugMode: Bool
       
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                if useGit {
                    Toggle(" Reset Git", isOn: $resetGit)
                    Toggle(" Push on Git commit", isOn: $pushOnGitMessage)
                    Toggle(" Push on Git tag", isOn: $pushOnGitTag)
                    Toggle(" Make Git branch", isOn: $makeGitBranch)
                    
                    if makeGitBranch {
                        Toggle(" Make Bitbucket Pr", isOn: $makeBitbucketPr)
                    }
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
                    Toggle(" Update Jira tickets", isOn: $updateJiraTickets)
                }
                
                Toggle(" Open ticket service now", isOn: $openTicketServiceNow)
                Toggle(" Send deploy email", isOn: $sendDeployEmail)
                Toggle(" Upload to AirWatch", isOn: $uploadToAirWatch)
                Toggle(" Enable debug mode", isOn: $debugMode)
            }
        }
    }
}

extension DeployApp {
    struct VersionAndBuildNumberView: View {
        
        @Binding var versionNumber: String
        @Binding var automaticVersionNumber: Bool
        @Binding var buildNumber: Int
        @Binding var automaticBuildNumber: Bool
        
        var body: some View {
            Group {
                HStack {
                    VersionNumberView(versionNumber: $versionNumber)
                        .opacity(automaticVersionNumber ? 0.5 : 1)
                        .disabled(automaticVersionNumber)
                    
                    Toggle(" Automatic", isOn: $automaticVersionNumber)
                }
                
                HStack {
                    BuildNumberView(buildNumber: $buildNumber)
                        .opacity(automaticBuildNumber ? 0.5 : 1)
                        .disabled(automaticBuildNumber)
                    
                    Toggle(" Automatic", isOn: $automaticBuildNumber)
                }
            }
        }
    }
}

// MARK: Pickers
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
        
        @Binding var selected: String
        
        let title: String
        let values: [String]
        let action: () -> Void
        
        var body: some View {
            
            HStack {
                Picker(title, selection: $selected) {
                    ForEach(values, id: \.self) {
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
    
    struct SprintPicker: View {
        
        private let network = Network.Jira()
        
        @Binding var selected: Network.Jira.Sprint
        
        @Binding var result: Result<[Network.Jira.Sprint], Error>?
        
        var body: some View {
            
            HStack {
                
                switch result {
                case .success(let sprints):
                    Picker("Selected Sprint:", selection: $selected) {
                        ForEach(sprints, id: \.self) {
                            Text($0.name).tag($0)
                        }
                    }
                case .failure(let error):
                    Text("Error while loading sprints")
                    Text(error.localizedDescription)
                case nil:
                    ProgressView()
                }
                
                if result != nil {
                    Button(systemImage: "arrow.counterclockwise") {
                        result = nil
                        Task {
                            await loadSprints()
                        }
                    }
                }
            }
            .task {
                switch result {
                case .success:
                    break
                default:
                    await loadSprints()
                }
            }
        }
        
        private func loadSprints() async {
            result = await network.fetchSprints().map {
                [.none] + Array($0)
            }
        }
    }
}

extension DeployApp: FastlaneWorkflow {}

private extension DeployApp {
    
    func fastlaneArguments(
        selectedScheme: String,
        buildNumber: Int?,
        incrementBuildNumber: Bool?,
        pushOnGitMessage: Bool,
        makeBitbucketPr: Bool,
        updateJiraTickets: Bool,
        openTicketServiceNow: Bool,
        sendDeployEmail: Bool,
        uploadToAirWatch: Bool
    ) -> FastlaneDeployArguments {
        FastlaneDeployArguments(
            xcode: selectedXcode,
            scheme: selectedScheme,
            versionNumber: versionNumberArg,
            buildNumber: buildNumber, 
            incrementBuildNumber: incrementBuildNumber,
            branchName: branchName,
            gitTag: gitTag,
            testers: testers,
            releaseNotes: releaseNotes,
            resetGit: resetGit,
            pushOnGitMessage: pushOnGitMessage,
            pushOnGitTag: pushOnGitTag,
            makeGitBranch: makeGitBranch,
            makeBitbucketPr: makeBitbucketPr,
            uploadToFirebase: uploadToFirebase,
            useCrashlytics: useCrashlytics,
            useDynatrace: uploadDsymToDynatrace,
            notifySlack: notifySlack,
            makeReleaseNotesFromJira: makeReleaseNotesFromJira,
            makeJiraRelease: makeJiraRelease, 
            updateJiraTickets: updateJiraTickets,
            sprint: selectedSprint,
            openTicketServiceNow: openTicketServiceNow,
            sendDeployEmail: sendDeployEmail, 
            uploadToAirWatch: uploadToAirWatch,
            debugMode: debugMode
        )
    }
    
    func firstFastlaneArguments(
        makeBitbucketPr: Bool,
        openTicketServiceNow: Bool,
        sendDeployEmail: Bool,
        uploadToAirWatch: Bool
    ) -> FastlaneDeployArguments {
        let buildNumber = buildNumberArg
        return fastlaneArguments(
            selectedScheme: firstSelectedScheme,
            buildNumber: buildNumber,
            incrementBuildNumber: buildNumber == nil ? true : nil,
            pushOnGitMessage: pushOnGitMessage,
            makeBitbucketPr: makeBitbucketPr,
            updateJiraTickets: updateJiraTickets,
            openTicketServiceNow: openTicketServiceNow,
            sendDeployEmail: sendDeployEmail,
            uploadToAirWatch: uploadToAirWatch
        )
    }
    
    func secondFastlaneArguments(
        pushOnGitMessage: Bool,
        updateJiraTickets: Bool
    ) -> FastlaneDeployArguments {
        let buildNumber = buildNumberArg
        return fastlaneArguments(
            selectedScheme: secondSelectedScheme,
            buildNumber: buildNumber,
            incrementBuildNumber: buildNumber == nil ? false : nil,
            pushOnGitMessage: pushOnGitMessage,
            makeBitbucketPr: makeBitbucketPr,
            updateJiraTickets: updateJiraTickets,
            openTicketServiceNow: openTicketServiceNow,
            sendDeployEmail: sendDeployEmail,
            uploadToAirWatch: uploadToAirWatch
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
        if makeBitbucketPr {
            commands.append(cpCredentialsBitbucket(projectFolder: folder))
        }
        if makeReleaseNotesFromJira || makeJiraRelease {
            commands.append(cpCredentialsJira(projectFolder: folder))
        }
        
        let isSelectedSecondScheme = secondSelectedScheme != noSelection
        
        let makeBitbucketPr = isSelectedSecondScheme ? false : self.makeBitbucketPr
        let openTicketServiceNow = isSelectedSecondScheme ? false : self.openTicketServiceNow
        let sendDeployEmail = isSelectedSecondScheme ? false : self.sendDeployEmail
        let uploadToAirWatch = isSelectedSecondScheme ? false : self.uploadToAirWatch
        
        commands.append(deployFirstScheme(
            makeBitbucketPr: makeBitbucketPr, 
            openTicketServiceNow: openTicketServiceNow,
            sendDeployEmail: sendDeployEmail,
            uploadToAirWatch: uploadToAirWatch
        ))
        
        if isSelectedSecondScheme {
            commands.append(deploySecondScheme(pushOnGitMessage: false, updateJiraTickets: false))
        }
        
        if makeBitbucketPr {
            commands.append(gitRestoreBitbucket())
        }
        
        if makeReleaseNotesFromJira || makeJiraRelease {
            commands.append(gitRestoreJira())
        }
        
        return runBundleScript(with: commands)
    }
    
    func deployFirstScheme(
        makeBitbucketPr: Bool,
        openTicketServiceNow: Bool,
        sendDeployEmail: Bool,
        uploadToAirWatch: Bool
    ) -> String {
        FastlaneCommand.deploy.fullCommand(with: firstFastlaneArguments(
            makeBitbucketPr: makeBitbucketPr, 
            openTicketServiceNow: openTicketServiceNow,
            sendDeployEmail: sendDeployEmail,
            uploadToAirWatch: uploadToAirWatch
        ))
    }
    
    func deploySecondScheme(pushOnGitMessage: Bool, updateJiraTickets: Bool) -> String {
        FastlaneCommand.deploy.fullCommand(with: secondFastlaneArguments(
            pushOnGitMessage: pushOnGitMessage,
            updateJiraTickets: updateJiraTickets
        ))
    }
    
    func update() {
        updateDeployButtonActivity()
        updateFastlaneCommand()
    }
    
    func updateFastlaneCommand() {
        if !firstSchemeFastlaneCommand.isEmpty {
            firstSchemeFastlaneCommand = ""
            firstSchemeFastlaneCommand = deployFirstScheme(
                makeBitbucketPr: makeBitbucketPr,
                openTicketServiceNow: openTicketServiceNow,
                sendDeployEmail: sendDeployEmail,
                uploadToAirWatch: uploadToAirWatch
            )
        }
        if !secondSchemeFastlaneCommand.isEmpty {
            secondSchemeFastlaneCommand = ""
            secondSchemeFastlaneCommand = deploySecondScheme(
                pushOnGitMessage: pushOnGitMessage,
                updateJiraTickets: updateJiraTickets
            )
        }
    }
    
    func updateDeployButtonActivity() {
        if automaticVersionNumber {
            disableDeploy = branchName.isEmpty
            return
        }
        
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
        
        let extracted = extract(at: path)
        
        let values = extracted.map {
            $0.replacingOccurrences(of: path + "/", with: "")
        }.map {
            $0.replacingOccurrences(of: "//", with: "/")
        }
        
        let branches = values.filter {
            $0 != ".DS_Store"
        }.sorted()
        
        self.values = [noSelection] + branches
    }
}

private struct GitTags {
    
    let values: [String]
    
    init() {
        let path = Defaults.shared.projectFolder + "/" + gitPathComponent + "/refs/tags"
        let tags = (try? FileManager.default.contentsOfDirectory(atPath: path))?.sorted() ?? []
        self.values = [noSelection] + tags
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
        DeployApp(sprints: .constant(nil))
    }
}

private extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
