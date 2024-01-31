//
//  BitbucketView.swift
//  Fastlane-UI
//
//  Created by softwave on 31/01/24.
//

import SwiftUI

struct BitbucketView: View {
    
    private let manager = ConfigurationManager()
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 10) {
                ForEach(BitbucketView.Config.allCases) {
                    ConfigItem(config: $0, configuration: manager.current)
                }
            }
        }
        .padding()
    }
}

extension BitbucketView {
    struct ConfigItem: View {
        
        let config: Config
        
        @State private var text: String
        
        init(config: Config, configuration: Configuration) {
            self.config = config
            
            switch config {
            case .companyHostName:
                text = configuration.companyHostName
            case .repositoryName:
                text = configuration.repositoryName
            case .title:
                text = configuration.title
            case .description:
                text = configuration.description
            case .sourceBranch:
                text = configuration.sourceBranch
            case .destinationBranch:
                text = configuration.destinationBranch
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


extension BitbucketView {
    
    enum Config: Int {
        case companyHostName
        case repositoryName
        case title
        case description
        case sourceBranch
        case destinationBranch
        
        var key: String {
            switch self {
            case .companyHostName:
                "COMPANY_HOST_NAME"
            case .repositoryName:
                "REPOSITORY_NAME"
            case .title:
                "TITLE"
            case .description:
                "DESCRIPTION"
            case .sourceBranch:
                "SOURCE_BRANCH"
            case .destinationBranch:
                "DESTINATION_BRANCH"
            }
        }
        
        var title: String {
            switch self {
            case .companyHostName:
                "Company Host"
            case .repositoryName:
                "Repository"
            case .title:
                "Title"
            case .description:
                "Description"
            case .sourceBranch:
                "Source branch"
            case .destinationBranch:
                "Destination branch"
            }
        }
    }
    
    private final class ConfigurationManager {
        
        var current = Configuration(companyHostName: "", 
                                    repositoryName: "",
                                    title: "",
                                    description: "",
                                    sourceBranch: "",
                                    destinationBranch: "")
        
        init() {
            if let config = try? readFromFile() {
                current = config
            }
        }
        
        func readFromFile() throws -> Configuration? {
            let path = Defaults.shared.projectFolder + "/" + fastlanePathComponent + "/" + ".bitbucket/config"
            let values = try String.contentsOfFileSeparatedByNewLine(path: path)
            
            var companyHostName: String?
            var repositoryName: String?
            var title: String?
            var description: String?
            var sourceBranch: String?
            var destinationBranch: String?
            
            func purge(value: String, config: BitbucketView.Config) -> String? {
                value.purge(using: config.key)
            }
            
            values.forEach {
                if let value = purge(value: $0, config: .companyHostName) {
                    companyHostName = value
                } else if let value = purge(value: $0, config: .repositoryName) {
                    repositoryName = value
                } else if let value = purge(value: $0, config: .title) {
                    title = value
                } else if let value = purge(value: $0, config: .description) {
                    description = value
                } else if let value = purge(value: $0, config: .sourceBranch) {
                    sourceBranch = value
                }  else if let value = purge(value: $0, config: .destinationBranch) {
                    destinationBranch = value
                }
            }
            
            guard let companyHostName, 
                    let repositoryName,
                    let title,
                    let description,
                    let sourceBranch,
                    let destinationBranch
            else { return nil }
              
            return Configuration(companyHostName: companyHostName,
                                 repositoryName: repositoryName,
                                 title: title,
                                 description: description,
                                 sourceBranch: sourceBranch,
                                 destinationBranch: destinationBranch)
        }
    }
    
    struct Configuration {
        let companyHostName: String
        let repositoryName: String
        let title: String
        let description: String
        let sourceBranch: String
        let destinationBranch: String
        
        var toFileContent: String {
            
            func line(config: BitbucketView.Config) -> String {
                let value = switch config {
                case .companyHostName:
                    companyHostName
                case .repositoryName:
                    repositoryName
                case .title:
                    title
                case .description:
                    description
                case .sourceBranch:
                    sourceBranch
                case .destinationBranch:
                    destinationBranch
                }
                return "\(config.key)=\"\(value)\"\n"
            }
            
            return """
            \(line(config: .companyHostName))
            \(line(config: .repositoryName))
            \(line(config: .title))
            \(line(config: .description))
            \(line(config: .sourceBranch))
            \(line(config: .destinationBranch))
            """
        }
    }
}

extension BitbucketView.Config: Identifiable {
    var id: Int {
        rawValue
    }
}

extension BitbucketView.Config: CaseIterable {}

