//
//  Bash_cd.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import Foundation

extension CommandExecuting {
    func cd(folder: String) throws -> String {
        try run(commandName: "cd", arguments: [folder])
    }
}
