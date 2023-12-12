//
//  FastlaneDeploy.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import Foundation

struct FastlaneDeployArguments: FastlaneArguments {
    let scheme: String
    let versionNumber: String
    let buildNumber: Int
    let branchName: String
    let testers: String
    let releaseNotes: String
    let pushOnGit: Bool
    let uploadToFirebase: Bool
    let useCrashlytics: Bool
    let useDynatrace: Bool
    let notifySlack: Bool
    let makeReleaseNotesFromJira: Bool
    
    private var envArg: String {
        let jsonPath = Defaults.shared.projectFolder + "/" + fastlanePathComponent + "/" + ".env_mapping.json"
       
        guard let data = try? Data(contentsOf: URL(filePath: jsonPath)) else {
            return "--env " + scheme
        }
        
        let mapping = try? JSONDecoder().decode([EnvMapping].self, from: data)

        let mapped = mapping?.first {
            $0.scheme == scheme
        }
        
        let env = mapped?.envName ?? scheme
        
        return "--env " + env
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
    
    private var useCrashlyticsArg: String? {
        useCrashlytics ? nil : "use_crashlytics:\(useCrashlytics)"
    }
    
    private var useDynatraceArg: String? {
        useDynatrace ? nil : "use_dynatrace:\(useDynatrace)"
    }
    
    private var notifySlackArg: String? {
        notifySlack ? nil : "use_slack:\(notifySlack)"
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
            useCrashlyticsArg,
            useDynatraceArg,
            notifySlackArg,
            makeReleaseNotesFromJiraArg
        ].compactMap{ $0 }
    }
}

extension CommandExecuting {
    func fastlaneDeploy(arguments: FastlaneDeployArguments) throws -> String {
        try fastlane(command: .deploy, arguments: arguments)
    }
}

private struct EnvMapping: Decodable {
    let scheme: String
    let envName: String
    
    enum CodingKeys: String, CodingKey {
        case scheme
        case envName = "env_name"
    }
}
