//
//  Git_restore.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import Foundation

extension CommandExecuting {
    
    func gitRestore(file: String) -> String {
        ["git", "restore", file].joined(separator: " ")
    }
    
    func runGitRestore(file: String) throws -> String {
        try run(commandName: "git", arguments: ["restore", file])
    }
}
