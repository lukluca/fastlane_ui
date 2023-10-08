//
//  FastlaneDeploy.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import Foundation

struct FastlaneDeployArguments: FastlaneArguments {
    let environment: Environment
    let versionNumber: String
    let buildNumber: Int
    let branchName: String
    let testers: String
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
    
    private var testersArg: String? {
        guard !testers.isEmpty else {
            return nil
        }
        return "testers:\(testers)"
    }
    
    private var relaseNotesArg: String? {
        guard !releaseNotes.isEmpty else {
            return nil
        }
        return "release_notes:\(releaseNotes)"
    }
    
    private var pushOnGitArg: String? {
        pushOnGit ? nil : "push_on_git:\(pushOnGit)"
    }
    
    private var uploadToFirebaseArg: String? {
        uploadToFirebase ? nil : "upload_to_firebase:\(uploadToFirebase)"
    }
    
    private var useSlackArg: String? {
        useSlack ? nil : "use_slack:\(useSlack)"
    }
    
    private var makeReleaseNotesFromJiraArg: String? {
        !makeReleaseNotesFromJira ? nil : "use_jira:\(makeReleaseNotesFromJira)"
    }
    
    var toArray: [String] {
        [
            envArg,
            versionNumberArg,
            buildNumberArg,
            branchNameArg,
            testersArg,
            relaseNotesArg,
            pushOnGitArg,
            uploadToFirebaseArg,
            useSlackArg,
            makeReleaseNotesFromJiraArg
        ].compactMap{ $0 }
    }
}

extension CommandExecuting {
    func fastlaneDeploy(arguments: FastlaneDeployArguments) throws -> String {
        try fastlane(command: .deploy, arguments: arguments)
    }
}
