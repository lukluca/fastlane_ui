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
        case schema
        case versionNumber
        case buildNumber
        //git
        case useGit
        case branchName
        case pushOnGit
        case cloneFromRemote
        case mainFolder
        case remoteURL
        //firebase
        case useFirebase
        case uploadToFirebase
        case testers
        case useCrashlytics
        //slack
        case useSlack
        case notifySlack
        //jira
        case useJira
        case jiraCredentialsFolder
        case makeReleaseNotesFromJira
        //settings
        case shell
        case needsSudo
    }
    
    @AppStorage(.showWizard) var showWizard = true
    //project
    @AppStorage(.projectFolder) var projectFolder = ""
    @AppStorage(.schema) var schema = ""
    @AppStorage(.versionNumber) var versionNumber = ""
    @AppStorage(.buildNumber) var buildNumber = 0
    //git
    @AppStorage(.useGit) var useGit = false
    @AppStorage(.branchName) var branchName = ""
    @AppStorage(.pushOnGit) var pushOnGit = false
    @AppStorage(.cloneFromRemote) var cloneFromRemote = false
    @AppStorage(.mainFolder) var mainFolder = ""
    @AppStorage(.remoteURL) var remoteURL = ""
    //firebase
    @AppStorage(.useFirebase) var useFirebase = false
    @AppStorage(.uploadToFirebase) var uploadToFirebase = false
    @AppStorage(.testers) var testers = ""
    @AppStorage(.useCrashlytics) var useCrashlytics = false
    //slack
    @AppStorage(.useSlack) var useSlack = false
    @AppStorage(.notifySlack) var notifySlack = false
    //jira
    @AppStorage(.useJira) var useJira = false
    @AppStorage(.jiraCredentialsFolder) var jiraCredentialsFolder = ""
    @AppStorage(.makeReleaseNotesFromJira) var makeReleaseNotesFromJira = false
    //settings
    @AppStorage(.shell) var shell = defaultShell
    @AppStorage(.needsSudo) var needsSudo = false
    
    static let shared = Defaults()
    
    func reset() {
        showWizard = true
        //project
        projectFolder = ""
        schema = ""
        versionNumber = ""
        buildNumber = 0
        //git
        useGit = false
        branchName = ""
        pushOnGit = false
        cloneFromRemote = false
        mainFolder = ""
        remoteURL = ""
        //firebase
        useFirebase = false
        uploadToFirebase = false
        testers = ""
        useCrashlytics = false
        //slack
        useSlack = false
        notifySlack = false
        //jira
        useJira = false
        jiraCredentialsFolder = ""
        makeReleaseNotesFromJira = false
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
