//
//  FastlaneDeploy.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import Foundation

struct FastlaneDeployArguments: FastlaneArguments {
    let scheme: String
    let versionNumber: String
    let buildNumber: Int
    let branchName: String
    let testers: String
    let releaseNotes: String
    let pushOnGit: Bool
    let uploadToFirebase: Bool
    let useCrashlytics: Bool
    let useDynatrace: Bool
    let notifySlack: Bool
    let makeReleaseNotesFromJira: Bool
    
    let defaultParameters = DefaultParameters()
    
    private var envArg: String {
        let jsonPath = Defaults.shared.projectFolder + "/" + fastlanePathComponent + "/" + ".env_mapping.json"
       
        guard let data = try? Data(contentsOf: URL(filePath: jsonPath)) else {
            return "--env " + scheme
        }
        
        let mapping = try? JSONDecoder().decode([EnvMapping].self, from: data)

        let mapped = mapping?.first {
            $0.scheme == scheme
        }
        
        let env = mapped?.envName ?? scheme
        
        return "--env " + env
    }
    
    private var versionNumberArg: String {
        "version_number:\(versionNumber)"
    }
    
    private var buildNumberArg: String {
        "build_number:\(buildNumber)"
    }
    
    private var branchNameArg: String {
        "branch_name:\\\"\(branchName)\\\""
    }
    
    private var testersArg: String? {
        guard !testers.isEmpty else {
            return nil
        }
        return "testers:\(testers)"
    }
    
    private var relaseNotesArg: String? {
        guard !releaseNotes.isEmpty else {
            return nil
        }
        return "release_notes:\\\"\(releaseNotes)\\\""
    }
    
    private var pushOnGitArg: String? {
        guard pushOnGit != defaultParameters.pushOnGit else {
            return nil
        }
        return "push_on_git:\(pushOnGit)"
    }
    
    private var uploadToFirebaseArg: String? {
        guard uploadToFirebase != defaultParameters.uploadToFirebase else {
            return nil
        }
        return "upload_to_firebase:\(uploadToFirebase)"
    }
    
    private var useCrashlyticsArg: String? {
        guard useCrashlytics != defaultParameters.useCrashlytics else {
            return nil
        }
        return "use_crashlytics:\(useCrashlytics)"
    }
    
    private var useDynatraceArg: String? {
        guard useDynatrace != defaultParameters.useDynatrace else {
            return nil
        }
        return "use_dynatrace:\(useDynatrace)"
    }
    
    private var notifySlackArg: String? {
        guard notifySlack != defaultParameters.useSlack else {
            return nil
        }
        return "use_slack:\(notifySlack)"
    }
    
    private var makeReleaseNotesFromJiraArg: String? {
        guard makeReleaseNotesFromJira != defaultParameters.useJira else {
            return nil
        }
        return "use_jira:\(makeReleaseNotesFromJira)"
    }
    
    var toArray: [String] {
        [
            envArg,
            versionNumberArg,
            buildNumberArg,
            branchNameArg,
            testersArg,
            relaseNotesArg,
            pushOnGitArg,
            uploadToFirebaseArg,
            useCrashlyticsArg,
            useDynatraceArg,
            notifySlackArg,
            makeReleaseNotesFromJiraArg
        ].compactMap{ $0 }
    }
}

extension CommandExecuting {
    func fastlaneDeploy(arguments: FastlaneDeployArguments) throws -> String {
        try fastlane(command: .deploy, arguments: arguments)
    }
}

private struct EnvMapping: Decodable {
    let scheme: String
    let envName: String
    
    enum CodingKeys: String, CodingKey {
        case scheme
        case envName = "env_name"
    }
}

extension FastlaneDeployArguments {
    struct DefaultParameters {
        
        let pushOnGit: Bool
        let useGitFlow: Bool
        let uploadToFirebase: Bool
        let useCrashlytics: Bool
        let useDynatrace: Bool
        let useSlack: Bool
        let useJira: Bool
        
        init() {
            let path = Defaults.shared.projectFolder + "/" + fastlanePathComponent + "/" + ".default_parameters"
            
            let values = (try? String.contentsOfFileSeparatedByNewLine(path: path)) ?? []
            
            var pushOnGit: Bool?
            var useGitFlow: Bool?
            var uploadToFirebase: Bool?
            var useCrashlytics: Bool?
            var useDynatrace: Bool?
            var useSlack: Bool?
            var useJira: Bool?
            
            func purge(value: String, parameter: Parameter) -> String? {
                value.purge(using: parameter.key)
            }
            
            values.forEach {
                if let value = purge(value: $0, parameter: .pushOnGit) {
                    pushOnGit = Bool(value)
                } else if let value = purge(value: $0, parameter: .useGitFlow) {
                    useGitFlow = Bool(value)
                } else if let value = purge(value: $0, parameter: .uploadToFirebase) {
                    uploadToFirebase = Bool(value)
                } else if let value = purge(value: $0, parameter: .useCrashlytics) {
                    useCrashlytics = Bool(value)
                } else if let value = purge(value: $0, parameter: .useDynatrace) {
                    useDynatrace = Bool(value)
                } else if let value = purge(value: $0, parameter: .useSlack) {
                    useSlack = Bool(value)
                } else if let value = purge(value: $0, parameter: .useJira) {
                    useJira = Bool(value)
                }
            }
            
            self.pushOnGit = pushOnGit ?? false
            self.useGitFlow = useGitFlow ?? false
            self.uploadToFirebase = uploadToFirebase ?? false
            self.useCrashlytics = useCrashlytics ?? false
            self.useDynatrace = useDynatrace ?? false
            self.useSlack = useSlack ?? false
            self.useJira = useJira ?? false
        }
    }
}

extension FastlaneDeployArguments.DefaultParameters {
    enum Parameter {
        
        case pushOnGit
        case useGitFlow
        case uploadToFirebase
        case useCrashlytics
        case useDynatrace
        case useSlack
        case useJira
        
        var key: String {
            switch self {
            case .pushOnGit:
                "PUSH_ON_GIT"
            case .useGitFlow:
                "USE_GIT_FLOW"
            case .uploadToFirebase:
                "UPLOAD_TO_FIREBASE"
            case .useCrashlytics:
                "USE_CRASHLYTICS"
            case .useDynatrace:
                "USE_DYNATRACE"
            case .useSlack:
                "USE_SLACK"
            case .useJira:
                "USE_JIRA"
            }
        }
    }
}
