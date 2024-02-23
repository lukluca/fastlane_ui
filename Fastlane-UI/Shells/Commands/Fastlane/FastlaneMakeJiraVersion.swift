//
//  FastlaneMakeJiraVersion.swift
//  Fastlane-UI
//
//  Created by softwave on 23/02/24.
//

import Foundation

struct FastlaneMakeJiraVersionArguments: FastlaneArguments {
    
    let versionNumber: String
    let buildNumber: Int
    
    private var versionNumberArg: String {
        "version_number:\(versionNumber)"
    }
    
    private var buildNumberArg: String {
        "build_number:\(buildNumber)"
    }
    
    var toArray: [String] {
        [versionNumberArg, buildNumberArg]
    }
}

extension CommandExecuting {
    func fastlaneMakeJiraVersion(arguments: FastlaneMakeJiraVersionArguments) throws -> String {
        try fastlane(command: .getJiraReleaseNotes, arguments: arguments)
    }
}

