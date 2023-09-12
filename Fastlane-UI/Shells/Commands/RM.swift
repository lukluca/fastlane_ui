//
//  RM.swift
//  Fastlane-UI
//
//  Created by softwave on 12/09/23.
//

import Foundation

extension CommandExecuting {
    func rm(path local: String) -> String {
        ["rm", "-r", local].joined(separator: " ")
    }
    
    func runRM(path local: String) throws -> String {
        try run(commandName: "rm", arguments: ["-r", local])
    }
}
