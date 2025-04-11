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
    
    struct TicketsManagement {
        let useSprintForQuery: Bool
        let useBranchForQuery: Bool
    }
}

extension Files.Jira.Credentials {
    
    struct Reader {
        
        private static let pathComponent = jiraPathComponent + "/" + "credentials"
        
        static func path() async -> String {
            await ProjectReader(pathComponent: pathComponent).path()
        }
        
        static func read() async throws -> Files.Jira.Credentials {
            try await ProjectReader(pathComponent: pathComponent).read(Files.Jira.Credentials.self)
        }
    }
}

extension Files.Jira.Credentials: Decodable {}

extension Files.Jira.Host {

    struct Reader {
        
        private static let pathComponent = jiraPathComponent + "/" + "host"
        
        static func path() async -> String {
            await ProjectReader(pathComponent: pathComponent).path()
        }
        
        static func read() async throws -> Files.Jira.Host {
            try await ProjectReader(pathComponent: pathComponent).read(Files.Jira.Host.self)
        }
    }
}

extension Files.Jira.Host: Decodable {}

extension Files.Jira.TicketsManagement {

    struct Reader {
        
        private static let pathComponent = jiraPathComponent + "/" + "tickets_management"
        
        static func path() async -> String {
            await ProjectReader(pathComponent: pathComponent).path()
        }
        
        static func read() async throws -> Files.Jira.TicketsManagement {
            let file = try await ProjectReader(pathComponent: pathComponent).read(Files.Jira.TicketsManagement.File.self)
            return Files.Jira.TicketsManagement(
                useSprintForQuery: file.useSprintForQuery.boolValue,
                useBranchForQuery: file.useBranchForQuery.boolValue,
            )
        }
    }
}

extension Files.Jira.TicketsManagement {
    private struct File: Decodable {
        let useSprintForQuery: String
        let useBranchForQuery: String
    }
}

private struct ProjectReader {
    
    let pathComponent: String
    
    func path() async -> String {
        await Defaults.shared.projectFolder + "/" + pathComponent
    }
    
    func read<T>(_ type: T.Type) async throws -> T where T : Decodable {
        try Files.decode(type, from: await path())
    }
}

private extension String {
    var boolValue: Bool {
        lowercased() == "true"
    }
}
