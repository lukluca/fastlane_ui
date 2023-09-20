//
//  Shell.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import Foundation

enum Shell: String, CaseIterable {
    case bash
    case zsh
}

extension Shell: CommandExecuting {
    var binPath: String {
        "/bin/" + rawValue
    }
}

extension Shell: Identifiable {
    var id: RawValue {
        rawValue
    }
}

protocol ShellWorkflow {
    var shell: Shell { get }
}

extension ShellWorkflow {
    func runBundleScript(with commands: [String]) -> String {
        do {
            try shell.prepareBundleScript(commands: commands)
            return try shell.runBundleScript()
        } catch {
            return error.localizedDescription
        }
    }
}
