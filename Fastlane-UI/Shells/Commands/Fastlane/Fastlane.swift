//
//  Fastlane.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import Foundation

let bundleCommand = "bundle"

enum FastlaneCommand: String {
    case deploy
    case getJiraReleaseNotes = "get_jira_release_notes"
    case updatePlugins = "update_plugins"
    case update = "update fastlane"
    
    private var needsExec: Bool {
        self != .update
    }
    
    fileprivate var arguments: [String] {
        if needsExec {
            return ["exec",
                    "fastlane",
                    rawValue]
        }
        return [rawValue]
    }
    
    func fullCommand(
        needsSudo: Bool = false,
        with arguments: FastlaneArguments = EmptyFastlaneArguments()
    ) -> String {
        let commands = ([bundleCommand] + self.arguments + arguments.toArray)
        return (needsSudo ?  ["sudo"] + commands : commands).joined(separator: " ")
    }
}

protocol FastlaneArguments {
    var toArray: [String] { get }
}

extension CommandExecuting {
    func fastlane(command: FastlaneCommand, arguments: FastlaneArguments) throws -> String {
        
        let allArguments = command.arguments + arguments.toArray
        
        return try run(
            commandName: bundleCommand,
            arguments: allArguments
        )
    }
}

struct EmptyFastlaneArguments: FastlaneArguments {
    let toArray: [String] = []
}

protocol FastlaneWorkflow: ShellWorkflow {}

extension FastlaneWorkflow {

    func cpCredentialsJira(credentialsFolder: String = Defaults.shared.jiraCredentialsFolder,
                           projectFolder: String) -> String {
        shell.cp(from: credentialsFolderPath(root: credentialsFolder),
                 to: projectFolder + "/" + jiraPathComponent)
    }
    
    func cpCredentialsBitbucket(projectFolder: String) -> String {
        shell.cp(from: credentialsFolderPath(root: Defaults.shared.bitbucketCredentialsFolder),
                 to: projectFolder + "/" + bitbucketPathComponent)
    }
    
    func gitRestoreJira() -> String {
        shell.gitRestore(file: jiraPathComponent + "/" + credentialsPathComponent)
    }
    
    func gitRestoreBitbucket() -> String {
        shell.gitRestore(file: bitbucketPathComponent + "/" + credentialsPathComponent)
    }
    
    private func credentialsFolderPath(root: String) -> String {
        root + "/" + credentialsPathComponent
    }
}
