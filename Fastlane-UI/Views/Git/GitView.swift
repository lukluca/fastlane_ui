//
//  GitView.swift
//  Fastlane-UI
//
//  Created by softwave on 24/11/23.
//

import SwiftUI

struct GitView: View {
    
    let shell = Defaults.shared.shell
    
    private var manager = ConfigurationManager()
    
    @Default(\.pushOnGitMessage) private var pushOnGitMessage: Bool
    @Default(\.pushOnGitTag) private var pushOnGitTag: Bool
    @Default(\.mainFolder) private var mainFolder: String
    @Default(\.remoteURL) private var remoteURL: String
    @Default(\.cloneFromRemote) private var cloneFromRemote: Bool
    @Default(\.makeGitBranch) private var makeGitBranch: Bool
    
    @State private var releaseBranchText: String = ""
    @State private var tagText: String = ""
    @State private var commitMessageText: String = ""
    
    @State private var isConfigurationChanged = false
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 10) {
                
                if pushOnGitMessage || pushOnGitTag || makeGitBranch {
                    ForEach(GitView.Config.allCases) {
                        switch $0 {
                        case .releaseBranch:
                            ConfigItem(title: $0.title, text: $releaseBranchText)
                        case .tag:
                            ConfigItem(title: $0.title, text: $tagText)
                        case .commitMessage:
                            ConfigItem(title: $0.title, text: $commitMessageText)
                        }
                    }
                    
                    Button("Reset") {
                        manager.reset()
                        reset()
                    }
                    .disabled(!isConfigurationChanged)
                    
                    Button("Save changes") {
                       save()
                    }
                    .disabled(!isConfigurationChanged)
                    
                    Button("Save, commit and push") {
                        save()
                        executeCommitAndPush()
                    }
                    .disabled(!isConfigurationChanged)
                }
                
                if cloneFromRemote {
                    MainFolderView(mainFolder: $mainFolder)
                    
                    HStack {
                        Text("Git remote url")
                        TextField("Enter your git remote url", text: $remoteURL)
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(" Push on Git commit", isOn: $pushOnGitMessage)
                    Toggle(" Push on Git tag", isOn: $pushOnGitTag)
                    Toggle(" Make Git branch", isOn: $makeGitBranch)
                    Toggle(" Clone git from remote", isOn: $cloneFromRemote)
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .onAppear {
            let manager = self.manager
            Task {
                await manager.setup()
                reset()
            }
        }
        .onChange(of: manager.current) {
            isConfigurationChanged = manager.isChanged
        }
        .onChange(of: releaseBranchText) { _, newValue in
            manager.current.releaseBranch = newValue
        }
        .onChange(of: tagText) { _, newValue in
            manager.current.tag = newValue
        }
        .onChange(of: commitMessageText) { _, newValue in
            manager.current.commitMessage = newValue
        }
    }
}

private extension GitView {
    
    func save() {
        let manager = self.manager
        Task {
            try? await manager.saveToFile()
            reset()
        }
    }
    
    func reset() {
        releaseBranchText = manager.current.releaseBranch
        tagText = manager.current.tag
        commitMessageText = manager.current.commitMessage
    }
    
    func executeCommitAndPush() {
        executeGitCommitAndPush(file: fastlanePathComponent + "/" + gitConfigNaming,
                                message: "Update git naming convention")
    }
}

extension GitView: GitShellWorkflow {}

extension GitView {
    struct ConfigItem: View {
        
        let title: String
        @Binding var text: String
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(title + ":")
                    
                    TextField("",
                              text: $text)
                    .textFieldStyle(.squareBorder)
                }
                
                Text("Example: " + text.replace)
                    .italic()
                    .foregroundStyle(.gray)
            }
        }
    }
}


extension GitView {
    
    enum Config: Int {
        case releaseBranch
        case tag
        case commitMessage
        
        var key: String {
            switch self {
            case .releaseBranch:
                "RELEASE_BRANCH"
            case .tag:
                "TAG"
            case .commitMessage:
                "COMMIT_MESSAGE"
            }
        }
        
        var title: String {
            switch self {
            case .releaseBranch:
                "Release branch"
            case .tag:
                "Tag"
            case .commitMessage:
                "Commit message"
            }
        }
    }
    
    @Observable
    final class ConfigurationManager {
        
        typealias Configuration = Files.Git.Naming
        
        private var file: Configuration
        var current: Configuration
        
        var isChanged: Bool {
            file != current
        }
 
        init() {
            file = Configuration(releaseBranch: "", tag: "", commitMessage: "")
            current = Configuration(releaseBranch: "", tag: "", commitMessage: "")
        }
        
        func setup() async {
            if let config = try? await Configuration.read() {
                file = config
                current = config
            }
        }
        
        func reset() {
            current = file
        }
        
        func saveToFile() async throws {
            try await Configuration.write(current)
            
            let config = try await Configuration.read()
            file = config
            current = config
        }
    }
}

extension GitView.Config: Identifiable {
    var id: Int {
        rawValue
    }
}

extension GitView.Config: CaseIterable {}
