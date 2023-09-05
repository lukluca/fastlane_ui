//
//  FastlaneGetJiraReleaseNotes.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import Foundation

struct FastlaneGetJiraReleaseNotesArguments: FastlaneArguments {
    
    let versionNumber: String
    
    private var versionNumberArg: String {
        "version_number:\(versionNumber)"
    }
    
    var toArray: [String] {
        [versionNumberArg]
    }
}

extension CommandExecuting {
    func fastlaneGetJiraReleaseNotes(arguments: FastlaneGetJiraReleaseNotesArguments) throws -> String {
        try fastlane(command: .getJiraReleaseNotes, arguments: arguments)
    }
}
