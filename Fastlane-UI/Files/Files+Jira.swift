//
//  Files+Jira.swift
//  Fastlane-UI
//
//  Created by softwave on 23/03/24.
//

import Foundation

extension Files {
    enum Jira {
    }
}

extension Files.Jira {
    struct Credentials {
        let username: String
        let token: String
    }
    
    struct Host {
        let url: String
        let project: String
    }
}

extension Files.Jira.Credentials {

    static func path() async -> String {
        await Task {
            Defaults.shared.projectFolder + "/" + jiraPathComponent + "/" + "credentials"
        }.value
    }
    
    static func read() async throws -> Files.Jira.Credentials {
        return try Files.decode(Files.Jira.Credentials.self, from:  await path())
    }
}

extension Files.Jira.Credentials: Decodable {}

extension Files.Jira.Host {
    
    static func path() async -> String {
        await Task {
            Defaults.shared.projectFolder + "/" + jiraPathComponent + "/" + "host"
        }.value
    }

    static func read() async throws -> Files.Jira.Host {
        try Files.decode(Files.Jira.Host.self, from: await path())
    }
}

extension Files.Jira.Host: Decodable {}



