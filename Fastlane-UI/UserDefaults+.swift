//
//  UserDefaults+.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import Foundation

extension UserDefaults {
    
    enum Key: String {
        case projectFolder
        case environment
        case versionNumber
        case buildNumber
        case branchName
        case pushOnGit
        case debugMode
    }
    
    var projectFolder: String? {
        get {
            string(for: .projectFolder)
        }
        set {
            set(newValue, for: .projectFolder)
        }
    }
    
    var environment: Environment? {
        get {
            guard let value = string(for: .environment) else {
                return nil
            }
            return Environment(rawValue: value)
        }
        set {
            set(newValue?.rawValue, for: .environment)
        }
    }
    
    var versionNumber: String? {
        get {
            string(for: .versionNumber)
        }
        set {
            set(newValue, for: .versionNumber)
        }
    }
    
    var buildNumber: String? {
        get {
            string(for: .buildNumber)
        }
        set {
            set(newValue, for: .buildNumber)
        }
    }
    
    var branchName: String? {
        get {
            string(for: .branchName)
        }
        set {
            set(newValue, for: .branchName)
        }
    }
    
    var pushOnGit: Bool? {
        get {
            boolValue(for: .pushOnGit)
        }
        set {
            set(newValue, for: .pushOnGit)
        }
    }
    
    var debugMode: Bool? {
        get {
            boolValue(for: .debugMode)
        }
        set {
            set(newValue, for: .debugMode)
        }
    }
    
    private func set(_ value: Any?, for key: Key) {
        set(value, forKey: key.rawValue)
    }
    
    private func string(for key: Key) -> String? {
        string(forKey: key.rawValue)
    }
    
    private func boolValue(for key: Key) -> Bool? {
        if value(forKey: key.rawValue) == nil {
            return nil
        }
        return bool(for: key)
    }
    
    private func bool(for key: Key) -> Bool {
        bool(forKey: key.rawValue)
    }
}
