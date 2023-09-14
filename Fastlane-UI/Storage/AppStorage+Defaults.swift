//
//  AppStorage+Defaults.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import SwiftUI

class Defaults: ObservableObject {
    
    fileprivate enum Key: String {
        case projectFolder
        case environment
        case versionNumber
        case buildNumber
        case branchName
        case pushOnGit
        case uploadToFirebase
        case useSlack
        case makeReleaseNotesFromJira
        case jiraCredentialsFolder
        case shell
        case cloneFromRemote
        case mainFolder
        case remoteURL
        case needsSudo
    }
    
    @AppStorage(.projectFolder) var projectFolder = ""
    @AppStorage(.environment) var environment = defaultEnvironment
    @AppStorage(.versionNumber) var versionNumber = ""
    @AppStorage(.buildNumber) var buildNumber: Int = 0
    @AppStorage(.branchName) var branchName = defaultBranchName
    @AppStorage(.pushOnGit) var pushOnGit = true
    @AppStorage(.uploadToFirebase) var uploadToFirebase = true
    @AppStorage(.useSlack) var useSlack = true
    @AppStorage(.makeReleaseNotesFromJira) var makeReleaseNotesFromJira = false
    @AppStorage(.jiraCredentialsFolder) var jiraCredentialsFolder = ""
    @AppStorage(.shell) var shell = defaultShell
    @AppStorage(.cloneFromRemote) var cloneFromRemote = true
    @AppStorage(.mainFolder) var mainFolder = ""
    @AppStorage(.remoteURL) var remoteURL = ""
    @AppStorage(.needsSudo) var needsSudo = false
    
    static let shared = Defaults()
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
