//
//  CP.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import Foundation

extension CommandExecuting {
    
    func cp(from origin: String, to destination: String) -> String {
        ["cp", "-R", origin, destination].joined(separator: " ")
    }
    
    func runCP(from origin: String, to destination: String) throws -> String {
        try run(commandName: "cp", arguments: ["-R", origin, destination])
    }
}
