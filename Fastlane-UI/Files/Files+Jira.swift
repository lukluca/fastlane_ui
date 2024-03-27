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

    static var path = Defaults.shared.projectFolder + "/" + jiraPathComponent + "/" + "credentials"
    
    static func read() throws -> Files.Jira.Credentials {
        try Files.decode(Files.Jira.Credentials.self, from: path)
    }
}

extension Files.Jira.Credentials: Decodable {}

extension Files.Jira.Host {

    static var path = Defaults.shared.projectFolder + "/" + jiraPathComponent + "/" + "host"
    
    static func read() throws -> Files.Jira.Host {
        try Files.decode(Files.Jira.Host.self, from: path)
    }
}

extension Files.Jira.Host: Decodable {}



