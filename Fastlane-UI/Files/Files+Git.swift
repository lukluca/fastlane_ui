//
//  Files+Git.swift
//  Fastlane-UI
//
//  Created by softwave on 23/03/24.
//

import Foundation

extension Files {
    enum Git {
    }
}

extension Files.Git {
    struct Naming {
        var releaseBranch: String
        var tag: String
        var commitMessage: String
    }
}

extension Files.Git.Naming {
    
    static func path() async -> String {
        await Task {
            projectFastlanePathComponent + "/" + gitConfigNaming
        }.value
    }

    static func read() async throws -> Files.Git.Naming {
        try Files.decode(Files.Git.Naming.self, from: await path())
    }
    
    static func write(_ obj: Files.Git.Naming) async throws {
        try Files.save(obj, to: await path())
    }
}

extension Files.Git.Naming: Codable {}

extension Files.Git.Naming: Equatable {}
