//
//  AppStorage+Defaults.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import SwiftUI

class Defaults: ObservableObject {
    
    fileprivate enum Key: String, CaseIterable {
        case showWizard
        //project
        case projectFolder
        case scheme
        case versionNumber
        case buildNumber
        //git
        case useGit
        case branchName
        case pushOnGit
        case cloneFromRemote
        case mainFolder
        case remoteURL
        case useGitFlow
        //bitbucket
        case useBitbucket
        case bitbucketCredentialsFolder
        //firebase
        case useFirebase
        case uploadToFirebase
        case testers
        case useCrashlytics
        //dynatrace
        case useDynatrace
        case uploadDsymToDynatrace
        //slack
        case useSlack
        case notifySlack
        //jira
        case useJira
        case jiraCredentialsFolder
        case makeReleaseNotesFromJira
        case makeJiraRelease
        case debugMode
        //settings
        case shell
        case needsSudo
    }
    
    @AppStorage(.showWizard) var showWizard = true
    //project
    @AppStorage(.projectFolder) var projectFolder = ""
    @AppStorage(.scheme) var scheme = ""
    @AppStorage(.versionNumber) var versionNumber = ""
    @AppStorage(.buildNumber) var buildNumber = 0
    //git
    @AppStorage(.useGit) var useGit = false
    @AppStorage(.branchName) var branchName = ""
    @AppStorage(.pushOnGit) var pushOnGit = false
    @AppStorage(.cloneFromRemote) var cloneFromRemote = false
    @AppStorage(.mainFolder) var mainFolder = ""
    @AppStorage(.remoteURL) var remoteURL = ""
    @AppStorage(.useGitFlow) var useGitFlow = false
    //bitbucket
    @AppStorage(.useBitbucket) var useBitbucket = false
    @AppStorage(.bitbucketCredentialsFolder) var bitbucketCredentialsFolder = ""
    //firebase
    @AppStorage(.useFirebase) var useFirebase = false
    @AppStorage(.uploadToFirebase) var uploadToFirebase = false
    @AppStorage(.testers) var testers = ""
    @AppStorage(.useCrashlytics) var useCrashlytics = false
    //dynatrace
    @AppStorage(.useDynatrace) var useDynatrace = false
    @AppStorage(.uploadDsymToDynatrace) var uploadDsymToDynatrace = false
    //slack
    @AppStorage(.useSlack) var useSlack = false
    @AppStorage(.notifySlack) var notifySlack = false
    //jira
    @AppStorage(.useJira) var useJira = false
    @AppStorage(.jiraCredentialsFolder) var jiraCredentialsFolder = ""
    @AppStorage(.makeReleaseNotesFromJira) var makeReleaseNotesFromJira = false
    @AppStorage(.makeJiraRelease) var makeJiraRelease = false
    @AppStorage(.debugMode) var debugMode = false
    //settings
    @AppStorage(.shell) var shell = defaultShell
    @AppStorage(.needsSudo) var needsSudo = false
    
    static let shared = Defaults()
    
    func reset() {
        showWizard = true
        //project
        projectFolder = ""
        scheme = ""
        versionNumber = ""
        buildNumber = 0
        //git
        useGit = false
        branchName = ""
        pushOnGit = false
        cloneFromRemote = false
        mainFolder = ""
        remoteURL = ""
        useGitFlow = false
        bitbucketCredentialsFolder = ""
        //bitbucket
        useBitbucket = false
        //firebase
        useFirebase = false
        uploadToFirebase = false
        testers = ""
        useCrashlytics = false
        //dynatrace
        useDynatrace = false
        uploadDsymToDynatrace = false
        //slack
        useSlack = false
        notifySlack = false
        //jira
        useJira = false
        jiraCredentialsFolder = ""
        makeReleaseNotesFromJira = false
        makeJiraRelease = false
        debugMode = false
        //settings
        shell = defaultShell
        needsSudo = false
    }
}

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
