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
        case branch
        case pushOnGit
        case debugMode
    }
    
    func setProjectFolder(_ value: String) {
        set(value, for: .projectFolder)
    }
    
    var projectFolder: String? {
        string(for: .projectFolder)
    }
    
    func setEnvironment(_ value: Environment) {
        set(value.rawValue, for: .environment)
    }
    
    var environment: Environment? {
        guard let value = string(for: .environment) else {
            return nil
        }
        return Environment(rawValue: value)
    }
    
    func setVersionNumber(_ value: String) {
        set(value, for: .versionNumber)
    }
    
    var versionNumber: String? {
        string(for: .versionNumber)
    }
    
    func setBuildNumber(_ value: String) {
        set(value, for: .buildNumber)
    }
    
    var buildNumber: String? {
        string(for: .buildNumber)
    }
    
    func setBranch(_ value: String) {
        set(value, for: .branch)
    }
    
    var branch: String? {
        string(for: .branch)
    }
    
    func setPushOnGit(_ value: Bool) {
        set(value, for: .pushOnGit)
    }
    
    var pushOnGit: Bool? {
        boolValue(for: .pushOnGit)
    }
    
    func setDebugMode(_ value: Bool) {
        set(value, for: .debugMode)
    }
    
    var debugMode: Bool? {
        boolValue(for: .debugMode)
    }
    
    private func set(_ value: Any, for key: Key) {
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
