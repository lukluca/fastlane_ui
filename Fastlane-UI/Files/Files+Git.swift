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

    @MainActor
    static var path = projectFastlanePathComponent + "/" + gitConfigNaming
    
    @MainActor
    static func read() throws -> Files.Git.Naming {
        try Files.decode(Files.Git.Naming.self, from: path)
    }
    
    @MainActor
    static func write(_ obj: Files.Git.Naming) throws {
        try Files.save(obj, to: path)
    }
}

extension Files.Git.Naming: Codable {}

extension Files.Git.Naming: Equatable {}
