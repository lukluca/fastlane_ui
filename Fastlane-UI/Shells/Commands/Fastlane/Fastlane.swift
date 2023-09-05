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
    
    var arguments: [String] {
        ["exec",
         "fastlane",
         rawValue]
    }
    
    func fullCommand(with arguments: FastlaneArguments) -> String {
        ([bundleCommand] + self.arguments + arguments.toArray).joined(separator: " ")
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
