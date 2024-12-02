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
    case makeJiraVersion = "make_jira_version"
    case updateBundle = "update --bundler"
    case updateFastlane = "update fastlane"
    case updatePlugins = "update_plugins"
    case updateFastlaneTools = "update_fastlane"
    case rubocop
    
    private var needsFastlane: Bool {
        self != .rubocop && self != .updateBundle && self != .updateFastlane
    }
    
    private var needsExec: Bool {
        self != .updateBundle && self != .updateFastlane
    }
    
    fileprivate var arguments: [String] {
    
        var commands = [String]()
        
        if needsExec {
            commands.append("exec")
        }
        
        if needsFastlane {
            commands.append("fastlane")
        }
    
        commands.append(rawValue)
        
        return commands
    }
    
    @MainActor
    func fullCommand(
        needsSudo: Bool = false,
        with arguments: FastlaneArguments = EmptyFastlaneArguments()
    ) -> String {
        let commands = ([bundleCommand] + self.arguments + arguments.toArray)
        return (needsSudo ?  ["sudo"] + commands : commands).joined(separator: " ")
    }
}

@MainActor
protocol FastlaneArguments {
    var toArray: [String] { get }
}

extension CommandExecuting {
    @MainActor
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

struct RubocopArguments: FastlaneArguments {
    let toArray: [String] = ["-A"]
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
