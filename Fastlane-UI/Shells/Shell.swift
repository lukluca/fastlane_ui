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
