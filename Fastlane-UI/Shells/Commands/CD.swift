//
//  CD.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import Foundation

extension CommandExecuting {
    
    func cd(folder: String) -> String {
        ["cd", folder].joined(separator: " ")
    }
    
    func runCD(folder: String) throws -> String {
        try run(commandName: "cd", arguments: [folder])
    }
}
