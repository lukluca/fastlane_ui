//
//  Shell.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import Foundation

enum Shell: String, CommandExecuting, CaseIterable {
    case bash = "/bin/bash"
    case zsh = "/bin/zsh"
}

extension Shell: TitleOwner {
    var title: String {
        switch self {
        case .bash:
            return "bash"
        case .zsh:
            return "zsh"
        }
    }
}
