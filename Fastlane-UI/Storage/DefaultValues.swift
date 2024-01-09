//
//  DefaultValues.swift
//  Fastlane-UI
//
//  Created by softwave on 06/09/23.
//

import Foundation

let defaultShell: Shell = .zsh

let credentialsPathComponent = "credentials"
let gitPathComponent = ".git"

let fastlanePathComponent = "fastlane"

var jiraPathComponent: String {
    fastlanePathComponent + "/" + ".jira"
}

private var firebasePathComponent: String {
    fastlanePathComponent + "/" + ".firebase"
}

var firebaseTestersPathComponent: String {
    firebasePathComponent + "/" + "testers"
}

var jiraWorkflowStatusPathComponent: String {
    jiraPathComponent + "/" + "workflow_status"
}

var dynatracePathComponent: String {
    fastlanePathComponent + "/" + ".dynatrace"
}
