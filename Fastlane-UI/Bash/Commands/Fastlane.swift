//
//  Fastlane.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import Foundation

struct FastlaneArguments {
    let environment: Environment
    let versionNumber: String
    let buildNumber: String
    let branchName: String
    let releaseNotes: String
    
    private var envArg: String {
        "--env " + environment.rawValue
    }
    
    private var versionNumberArg: String {
        "version_number:\(versionNumber)"
    }
    
    private var buildNumberArg: String {
        "build_number:\(buildNumber)"
    }
    
    private var branchNameArg: String {
        "branch_name:\(branchName)"
    }
    
    private var releaseNotesArg: String {
        "release_notes:\(releaseNotes)"
    }
    
    var toArray: [String] {
        [envArg, versionNumberArg, buildNumberArg, branchName, releaseNotes]
    }
}

extension CommandExecuting {
    func fastlane(arguments: FastlaneArguments) throws -> String {
        try run(
            commandName: "bundle",
            arguments: ["exec", "fastlane", "deploy"] + arguments.toArray
        )
    }
}
