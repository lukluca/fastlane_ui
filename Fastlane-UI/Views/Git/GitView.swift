//
//  GitView.swift
//  Fastlane-UI
//
//  Created by softwave on 24/11/23.
//

import SwiftUI

struct GitView: View {
    
    private let manager = ConfigurationManager()
    
    @Default(\.pushOnGit) private var pushOnGit: Bool
    @Default(\.mainFolder) private var mainFolder: String
    @Default(\.remoteURL) private var remoteURL: String
    @Default(\.cloneFromRemote) private var cloneFromRemote: Bool
    @Default(\.useGitFlow) private var useGitFlow: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 10) {
                
                if pushOnGit || useGitFlow {
                    ForEach(GitView.Config.allCases) {
                        ConfigItem(config: $0, configuration: manager.current)
                    }
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
    }
}

extension GitView {
    struct ConfigItem: View {
        
        let config: Config
        
        @State private var text: String
        
        init(config: Config, configuration: Configuration) {
            self.config = config
            
            switch config {
            case .releaseBranch:
                text = configuration.releaseBranch
            case .tag:
                text = configuration.tag
            case .commitMessage:
                text = configuration.commitMessage
            }
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(config.title + ":")
                    
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
    
    private final class ConfigurationManager {
        
        var current = Configuration(releaseBranch: "", tag: "", commitMessage: "")
        
        init() {
            if let config = try? readFromFile() {
                current = config
            }
        }
        
        func readFromFile() throws -> Configuration? {
            let path = Defaults.shared.projectFolder + "/" + fastlanePathComponent + "/" + ".git_config/naming"
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
        let releaseBranch: String
        let tag: String
        let commitMessage: String
        
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
                return "\(config.key)=\"\(value)\"\n"
            }
            
            return """
            \(line(config: .releaseBranch))
            \(line(config: .tag))
            \(line(config: .commitMessage))
            """
        }
    }
}

extension GitView.Config: Identifiable {
    var id: Int {
        rawValue
    }
}

extension GitView.Config: CaseIterable {}
