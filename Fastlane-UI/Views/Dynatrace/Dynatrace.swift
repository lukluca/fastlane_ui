//
//  Dynatrace.swift
//  Fastlane-UI
//
//  Created by softwave on 09/01/24.
//

import SwiftUI

struct Dynatrace: View {
    
    private let manager = ConfigurationManager()
    
    @State private var text = ""
    
    @Default(\.uploadDsymToDynatrace) private var uploadDsymToDynatrace
    
    var body: some View {
        VStack {
            
            ForEach(Dynatrace.Config.allCases) {
                ConfigItem(config: $0, configuration: manager.current)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Toggle(" Upload dsym to Dynatrace", isOn: $uploadDsymToDynatrace)
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

extension Dynatrace {
    struct ConfigItem: View {
        
        let config: Config
        
        @State private var text: String
        
        init(config: Config, configuration: Configuration) {
            self.config = config
            
            switch config {
            case .appId:
                text = configuration.appId
            case .server:
                text = configuration.server
            case .apiToken:
                text = configuration.apiToken
            }
        }
        
        var body: some View {
            HStack {
                Text(config.title + ":")
                
                TextField("",
                          text: $text)
                .textFieldStyle(.squareBorder)
            }
        }
    }
}

extension Dynatrace {
    
    enum Config: Int {
        case appId
        case server
        case apiToken
        
        var key: String {
            switch self {
            case .appId:
                "APP_ID"
            case .server:
                "SERVER"
            case .apiToken:
                "API_TOKEN"
            }
        }
        
        var title: String {
            switch self {
            case .appId:
                "App ID"
            case .server:
                "Server"
            case .apiToken:
                "Api Token"
            }
        }
    }
    
    private final class ConfigurationManager {
        
        var current = Configuration(appId: "", server: "", apiToken: "")
        
        init() {
            if let config = try? readFromFile() {
                current = config
            }
        }
        
        func readFromFile() throws -> Configuration? {
            let path = Defaults.shared.projectFolder + "/" + dynatracePathComponent + "/config"
            let values = try String.contentsOfFileSeparatedByNewLine(path: path)
            
            var appId: String?
            var server: String?
            var apiToken: String?
            
            func purge(value: String, config: Dynatrace.Config) -> String? {
                value.purge(using: config.key)
            }
            
            values.forEach {
                if let value = purge(value: $0, config: .appId) {
                    appId = value
                } else if let value = purge(value: $0, config: .server) {
                    server = value
                } else if let value = purge(value: $0, config: .apiToken) {
                    apiToken = value
                }
            }
            
            guard let appId, let server, let apiToken
            else { return nil }
              
            return Configuration(appId: appId,
                                 server: server,
                                 apiToken: apiToken)
        }
    }
    
    struct Configuration {
        let appId: String
        let server: String
        let apiToken: String
        
        var toFileContent: String {
            
            func line(config: Dynatrace.Config) -> String {
                let value = switch config {
                case .appId:
                    appId
                case .server:
                    server
                case .apiToken:
                    apiToken
                }
                return "\(config.key)=\"\(value)\"\n"
            }
            
            return """
            \(line(config: .appId))
            \(line(config: .server))
            \(line(config: .apiToken))
            """
        }
    }
}

extension Dynatrace.Config: Identifiable {
    var id: Int {
        rawValue
    }
}

extension Dynatrace.Config: CaseIterable {}
