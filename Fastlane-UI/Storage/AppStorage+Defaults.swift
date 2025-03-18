//
//  AppStorage+Defaults.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import SwiftUI

let defaultShell: Shell = .zsh

@MainActor
final class Defaults: ObservableObject {
    
    fileprivate enum Key: String, CaseIterable {
        // wizard
        case showWizard
        case isGitChoosen
        case isBitBucketChoosen
        case isFirebaseChoosen
        case isDynatraceChoosen
        case isJiraChoosen
        case isSlackChoosen
        case isTeamsChoosen
        // project
        case projectFolder
        case xcode
        case firstScheme
        case secondScheme
        case thirdScheme
        case versionNumber
        case automaticVersionNumber
        case buildNumber
        case automaticBuildNumber
        // git
        case useGit
        case branchName
        case gitTag
        case resetGit
        case pushOnGitMessage
        case pushOnGitTag
        case cloneFromRemote
        case mainFolder
        case remoteURL
        case makeGitBranch
        // bitbucket
        case makeBitbucketPr
        case bitbucketCredentialsFolder
        // firebase
        case useFirebase
        case uploadToFirebase
        case testers
        case useCrashlytics
        // dynatrace
        case useDynatrace
        case uploadDsymToDynatrace
        // slack
        case useSlack
        case notifySlack
        // teams
        case useTeams
        case notifyTeams
        // jira
        case useJira
        case jiraCredentialsFolder
        case makeReleaseNotesFromJira
        case makeJiraRelease
        case updateJiraTickets
        case debugMode
        // settings
        case shell
        case needsSudo
        // serviceNow
        case openTicketServiceNow
        // mail
        case sendDeployEmail
        // AirWatch
        case uploadToAirWatch
    }
    
    // wizard
    @AppStorage(.showWizard) var showWizard = true
    @AppStorage(.isGitChoosen) var isGitChoosen = false
    @AppStorage(.isBitBucketChoosen) var isBitBucketChoosen = false
    @AppStorage(.isFirebaseChoosen) var isFirebaseChoosen = false
    @AppStorage(.isDynatraceChoosen) var isDynatraceChoosen = false
    @AppStorage(.isJiraChoosen) var isJiraChoosen = false
    @AppStorage(.isSlackChoosen) var isSlackChoosen = false
    @AppStorage(.isTeamsChoosen) var isTeamsChoosen = false
    // project
    @AppStorage(.projectFolder) var projectFolder = ""
    @AppStorage(.xcode) var xcode = ""
    @AppStorage(.firstScheme) var firstScheme = ""
    @AppStorage(.secondScheme) var secondScheme = ""
    @AppStorage(.thirdScheme) var thirdScheme = ""
    @AppStorage(.versionNumber) var versionNumber = ""
    @AppStorage(.automaticVersionNumber) var automaticVersionNumber = false
    @AppStorage(.buildNumber) var buildNumber = 0
    @AppStorage(.automaticBuildNumber) var automaticBuildNumber = false
    // git
    @AppStorage(.useGit) var useGit = false
    @AppStorage(.branchName) var branchName = ""
    @AppStorage(.gitTag) var gitTag = ""
    @AppStorage(.resetGit) var resetGit = false
    @AppStorage(.pushOnGitMessage) var pushOnGitMessage = false
    @AppStorage(.pushOnGitTag) var pushOnGitTag = false
    @AppStorage(.cloneFromRemote) var cloneFromRemote = false
    @AppStorage(.mainFolder) var mainFolder = ""
    @AppStorage(.remoteURL) var remoteURL = ""
    @AppStorage(.makeGitBranch) var makeGitBranch = false
    // bitbucket
    @AppStorage(.makeBitbucketPr) var makeBitbucketPr = false
    @AppStorage(.bitbucketCredentialsFolder) var bitbucketCredentialsFolder = ""
    // firebase
    @AppStorage(.useFirebase) var useFirebase = false
    @AppStorage(.uploadToFirebase) var uploadToFirebase = false
    @AppStorage(.testers) var testers = ""
    @AppStorage(.useCrashlytics) var useCrashlytics = false
    // dynatrace
    @AppStorage(.useDynatrace) var useDynatrace = false
    @AppStorage(.uploadDsymToDynatrace) var uploadDsymToDynatrace = false
    // slack
    @AppStorage(.useSlack) var useSlack = false
    @AppStorage(.notifySlack) var notifySlack = false
    // teams
    @AppStorage(.useTeams) var useTeams = false
    @AppStorage(.notifyTeams) var notifyTeams = false
    // jira
    @AppStorage(.useJira) var useJira = false
    @AppStorage(.jiraCredentialsFolder) var jiraCredentialsFolder = ""
    @AppStorage(.makeReleaseNotesFromJira) var makeReleaseNotesFromJira = false
    @AppStorage(.makeJiraRelease) var makeJiraRelease = false
    @AppStorage(.updateJiraTickets) var updateJiraTickets = false
    @AppStorage(.debugMode) var debugMode = false
    // settings
    @AppStorage(.shell) var shell = defaultShell
    @AppStorage(.needsSudo) var needsSudo = false
    // serviceNow
    @AppStorage(.openTicketServiceNow) var openTicketServiceNow = false
    // mail
    @AppStorage(.sendDeployEmail) var sendDeployEmail = false
    // AirWatch
    @AppStorage(.uploadToAirWatch) var uploadToAirWatch = false
    
    static let shared = Defaults()
    
    func resetToFile() {
        let defaultParameters = FastlaneDeployArguments.DefaultParameters()
        
        xcode = defaultParameters.xcode
        resetGit = defaultParameters.resetGit
        pushOnGitMessage = defaultParameters.pushOnGitMessage
        pushOnGitTag = defaultParameters.pushOnGitTag
        makeGitBranch = defaultParameters.makeGitBranch
        makeBitbucketPr = defaultParameters.makeBitbucketPr
        uploadToFirebase = defaultParameters.uploadToFirebase
        useCrashlytics = defaultParameters.useCrashlytics
        uploadDsymToDynatrace = defaultParameters.useDynatrace
        notifySlack = defaultParameters.useSlack
        notifyTeams = defaultParameters.useTeams
        makeReleaseNotesFromJira = defaultParameters.useJiraReleaseNotes
        makeJiraRelease = defaultParameters.makeJiraRelease
        updateJiraTickets = defaultParameters.updateJiraTickets
        debugMode = defaultParameters.debugMode
        openTicketServiceNow = defaultParameters.openTicketServiceNow
        sendDeployEmail = defaultParameters.sendDeployEmail
        uploadToAirWatch = defaultParameters.uploadToAirWatch
    }
    
    func reset() {
        showWizard = true
        isGitChoosen = false
        isBitBucketChoosen = false
        isFirebaseChoosen = false
        isDynatraceChoosen = false
        isJiraChoosen = false
        isSlackChoosen = false
        isTeamsChoosen = false
        // project
        projectFolder = ""
        xcode = ""
        firstScheme = ""
        secondScheme = ""
        thirdScheme = ""
        versionNumber = ""
        automaticVersionNumber = false
        buildNumber = 0
        automaticBuildNumber = false
        // git
        useGit = false
        branchName = ""
        gitTag = ""
        resetGit = false
        pushOnGitMessage = false
        pushOnGitTag = false
        cloneFromRemote = false
        mainFolder = ""
        remoteURL = ""
        makeGitBranch = false
        // bitbucket
        bitbucketCredentialsFolder = ""
        makeBitbucketPr = false
        // firebase
        useFirebase = false
        uploadToFirebase = false
        testers = ""
        useCrashlytics = false
        // dynatrace
        useDynatrace = false
        uploadDsymToDynatrace = false
        // slack
        useSlack = false
        notifySlack = false
        // teams
        useTeams = false
        notifyTeams = false
        // jira
        useJira = false
        jiraCredentialsFolder = ""
        makeReleaseNotesFromJira = false
        makeJiraRelease = false
        updateJiraTickets = false
        debugMode = false
        // settings
        shell = defaultShell
        needsSudo = false
        // serviceNow
        openTicketServiceNow = false
        // email
        sendDeployEmail = false
        // AirWatch
        uploadToAirWatch = false
    }
}

@MainActor
@propertyWrapper
struct Default<T>: DynamicProperty {
    @ObservedObject private var defaults: Defaults
    private let keyPath: ReferenceWritableKeyPath<Defaults, T>
    init(_ keyPath: ReferenceWritableKeyPath<Defaults, T>, defaults: Defaults = .shared) {
        self.keyPath = keyPath
        self.defaults = defaults
    }

    var wrappedValue: T {
        get { defaults[keyPath: keyPath] }
        nonmutating set { defaults[keyPath: keyPath] = newValue }
    }

    var projectedValue: Binding<T> {
        Binding(
            get: { defaults[keyPath: keyPath] },
            set: { value in
                defaults[keyPath: keyPath] = value
            }
        )
    }
}

private extension AppStorage {
    init(wrappedValue: Value, _ key: Defaults.Key)  where Value == String {
        self.init(wrappedValue: wrappedValue, key.rawValue)
    }
    
    init(wrappedValue: Value, _ key: Defaults.Key)  where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue)
    }
    
    init(wrappedValue: Value, _ key: Defaults.Key)  where Value == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue)
    }
    
    init(wrappedValue: Value, _ key: Defaults.Key)  where Value : RawRepresentable, Value.RawValue == String {
        self.init(wrappedValue: wrappedValue, key.rawValue)
    }
}
