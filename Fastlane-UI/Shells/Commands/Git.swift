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

extension CommandExecuting {
    
    private func encapsulate(_ message: String) -> String {
        "\\\"" + message + "\\\""
    }
    
    func gitCommit(message: String) -> String {
        [git, "commit", "-m", encapsulate(message)].joined(separator: " ")
    }
    
    func runGitCommit(message: String) throws -> String {
        try run(commandName: "git", arguments: ["commit", "-m", encapsulate(message)])
    }
}

extension CommandExecuting {
    func gitPush(branch: String) -> String {
        [git, "push", "origin", branch].joined(separator: " ")
    }
    
    func runGitPush(branch: String) throws -> String {
        try run(commandName: "git", arguments: ["push", "origin", branch])
    }
}

extension CommandExecuting {
    func gitCheckout(branch: String) -> String {
        [git, "checkout", branch].joined(separator: " ")
    }
    
    func runGitCheckout(branch: String) throws -> String {
        try run(commandName: "git", arguments: ["checkout", branch])
    }
}

extension CommandExecuting {
    func gitAdd(file: String) -> String {
        [git, "add", file].joined(separator: " ")
    }
    
    func runGitAdd(file: String) throws -> String {
        try run(commandName: "git", arguments: ["add", file])
    }
}

protocol GitShellWorkflow: ShellWorkflow {}

extension GitShellWorkflow {
    func executeGitCommitAndPush(file: String, message: String) {
        let branch = Defaults.shared.branchName
        let cd = shell.cd(folder: Defaults.shared.projectFolder)
        let checkout = shell.gitCheckout(branch: branch)
        let add = shell.gitAdd(file: file)
        let commit = shell.gitCommit(message: message)
        let push = shell.gitPush(branch: branch)
        
        let _ = runBundleScript(with: [cd, checkout, add, commit, push])
    }
}
