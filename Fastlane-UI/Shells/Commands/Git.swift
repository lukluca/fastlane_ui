//
//  Git_restore.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import Foundation

private let git = "git"

extension CommandExecuting {
    
    func gitRestore(file: String) -> String {
        [git, "restore", file].joined(separator: " ")
    }
    
    func runGitRestore(file: String) throws -> String {
        try run(commandName: "git", arguments: ["restore", file])
    }
}

extension CommandExecuting {
    func gitClone(remoteURL: String) -> String {
        [git, "clone", remoteURL].joined(separator: " ")
    }
    
    func runGitClone(remoteURL: String) throws -> String {
        try run(commandName: "git", arguments: ["clone", remoteURL])
    }
}

extension CommandExecuting {
    func gitFetchOrigin() -> String {
        [git, "fetch", "origin"].joined(separator: " ")
    }
    
    func runGitFetchOrigin() throws -> String {
        try run(commandName: "git", arguments: ["fetch", "origin"])
    }
}

extension CommandExecuting {
    func gitSwitch(branch: String) -> String {
        [git, "switch", branch].joined(separator: " ")
    }
    
    func runGitSwitch(branch: String) throws -> String {
        try run(commandName: "git", arguments: ["switch", branch])
    }
}
