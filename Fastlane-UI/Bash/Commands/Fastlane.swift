//
//  Fastlane.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import Foundation


let bundleCommand = "bundle"

struct FastlaneArguments {
    let environment: Environment
    let versionNumber: String
    let buildNumber: String
    let branchName: String
    let releaseNotes: String
    let pushOnGit: Bool
    let uploadToFirebase: Bool
    let useSlack: Bool
    let makeReleaseNotesFromJira: Bool
    
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
    
    private var relaseNotesArg: String? {
        guard !releaseNotes.isEmpty else {
            return nil
        }
        return "release_notes:\(releaseNotes)"
    }
    
    private var pushOnGitArg: String {
        "push_on_git:\(pushOnGit)"
    }
    
    private var uploadToFirebaseArg: String {
        "upload_to_firebase:\(uploadToFirebase)"
    }
    
    private var useSlackArg: String {
        "use_slack:\(useSlack)"
    }
    
    private var makeReleaseNotesFromJiraArg: String {
        "use_jira:\(makeReleaseNotesFromJira)"
    }
    
    var toArray: [String] {
        let args = ["exec",
         "fastlane",
         "deploy",
         envArg,
         versionNumberArg,
         buildNumberArg,
         branchNameArg,
         pushOnGitArg,
         uploadToFirebaseArg,
         useSlackArg,
         makeReleaseNotesFromJiraArg]
        
        if let relaseNotesArg {
            return args + [relaseNotesArg]
        }
        
        return args
    }
}

extension CommandExecuting {
    func fastlane(arguments: FastlaneArguments) throws -> String {
        try run(
            commandName: bundleCommand,
            arguments: arguments.toArray
        )
    }
}
