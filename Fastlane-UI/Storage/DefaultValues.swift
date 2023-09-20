//
//  DefaultValues.swift
//  Fastlane-UI
//
//  Created by softwave on 06/09/23.
//

import Foundation

let defaultBranchName = "develop"
let defaultShell: Shell = .zsh
let defaultEnvironment: Environment = .test


let jiraPathComponent = "fastlane/.jira"

var jiraWorkflowStatusPathComponent: String {
    jiraPathComponent + "/" + "workflow_status"
}
