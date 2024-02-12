//
//  GitView.swift
//  Fastlane-UI
//
//  Created by softwave on 24/11/23.
//

import SwiftUI

struct GitView: View {
    
    let shell = Defaults.shared.shell
    
    @ObservedObject private var manager = ConfigurationManager()
    
    @Default(\.pushOnGit) private var pushOnGit: Bool
    @Default(\.mainFolder) private var mainFolder: String
    @Default(\.remoteURL) private var remoteURL: String
    @Default(\.cloneFromRemote) private var cloneFromRemote: Bool
    @Default(\.useGitFlow) private var useGitFlow: Bool
    
    @State private var releaseBranchText: String = ""
    @State private var tagText: String = ""
    @State private var commitMessageText: String = ""
    
    @State private var isConfigurationChanged = false
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 10) {
                
                if pushOnGit || useGitFlow {
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
                    Toggle(" Push on Git tag and commit", isOn: $pushOnGit)
                    Toggle(" Use GitFlow", isOn: $useGitFlow)
                    Toggle(" Clone git from remote", isOn: $cloneFromRemote)
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .onAppear {
            reset()
        }
        .onChange(of: manager.current) { _ in
            isConfigurationChanged = manager.isChanged
        }
        .onChange(of: releaseBranchText) { newValue in
            manager.current.releaseBranch = newValue
        }
        .onChange(of: tagText) { newValue in
            manager.current.tag = newValue
        }
        .onChange(of: commitMessageText) { newValue in
            manager.current.commitMessage = newValue
        }
    }
}

private extension GitView {
    
    func save() {
        try? manager.saveToFile()
        reset()
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
    
    private final class ConfigurationManager: ObservableObject {
        
        private var file: Configuration
        @Published var current: Configuration
        
        var isChanged: Bool {
            file != current
        }
 
        init() {
            if let config = try? ConfigurationManager.readFromFile() {
                file = config
                current = config
            } else {
                file = Configuration(releaseBranch: "", tag: "", commitMessage: "")
                current = Configuration(releaseBranch: "", tag: "", commitMessage: "")
            }
        }
        
        func reset() {
            current = file
        }
        
        func saveToFile() throws {
            let path = projectFastlanePathComponent + "/" + gitConfigNaming
            try current.toFileContent.write(toFile: path, atomically: true, encoding: .utf8)
            
            if let config = try ConfigurationManager.readFromFile() {
                file = config
                current = config
            }
        }
        
        private static func readFromFile() throws -> Configuration? {
            let path = projectFastlanePathComponent + "/" + gitConfigNaming
            let values = try String.contentsOfFileSeparatedByNewLine(path: path)
            
            var releaseBranch: String?
            var tag: String?
            var commitMessage: String?
            
            func purge(value: String, config: GitView.Config) -> String? {
                value.purge(using: config.key)
            }
            
            values.forEach {
                if let value = purge(value: $0, config: .releaseBranch) {
                    releaseBranch = value
                } else if let value = purge(value: $0, config: .tag) {
                    tag = value
                } else if let value = purge(value: $0, config: .commitMessage) {
                    commitMessage = value
                }
            }
            
            guard let releaseBranch, let tag, let commitMessage
            else { return nil }
              
            return Configuration(releaseBranch: releaseBranch,
                                 tag: tag,
                                 commitMessage: commitMessage)
        }
    }
    
    struct Configuration {
        var releaseBranch: String
        var tag: String
        var commitMessage: String
        
        var toFileContent: String {
            
            func line(config: GitView.Config) -> String {
                let value = switch config {
                case .releaseBranch:
                    releaseBranch
                case .tag:
                    tag
                case .commitMessage:
                    commitMessage
                }
                return "\(config.key)=\(value)"
            }
            
            return """
            \(line(config: .releaseBranch))
            \(line(config: .tag))
            \(line(config: .commitMessage))
            """
        }
    }
}

extension GitView.Configuration: Equatable {}

extension GitView.Config: Identifiable {
    var id: Int {
        rawValue
    }
}

extension GitView.Config: CaseIterable {}
