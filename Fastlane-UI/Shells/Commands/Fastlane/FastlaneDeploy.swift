//
//  FastlaneDeploy.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import Foundation

let noSelection: String = "None"

struct FastlaneDeployArguments: FastlaneArguments {
    let xcode: String
    let scheme: String
    let versionNumber: String
    let buildNumber: Int
    let branchName: String
    let gitTag: String
    let testers: String
    let releaseNotes: String
    let resetGit: Bool
    let pushOnGitMessage: Bool
    let pushOnGitTag: Bool
    let makeGitBranch: Bool
    let makeBitbucketPr: Bool
    let uploadToFirebase: Bool
    let useCrashlytics: Bool
    let useDynatrace: Bool
    let notifySlack: Bool
    let makeReleaseNotesFromJira: Bool
    let makeJiraRelease: Bool
    let updateJiraTickets: Bool
    let sprint: Network.Jira.Sprint
    let debugMode: Bool
    
    let defaultParameters = DefaultParameters()
    
    private var xcodeArg: String? {
        guard xcode != defaultParameters.xcode else {
            return nil
        }
        return "xcode:\(xcode)"
    }
    
    private var envArg: String {
        "--env " + scheme.asEnvironment
    }
    
    private var versionNumberArg: String {
        "version_number:\(versionNumber)"
    }
    
    private var buildNumberArg: String {
        "build_number:\(buildNumber)"
    }
    
    private var branchNameArg: String? {
        guard branchName != noSelection else {
            return nil
        }
        return escape(key: "branch_name", value: branchName)
    }
    
    private var gitTagArg: String? {
        guard gitTag != noSelection else {
            return nil
        }
        return escape(key: "git_tag", value: gitTag)
    }
    
    private var testersArg: String? {
        guard !testers.isEmpty else {
            return nil
        }
        return "testers:\(testers)"
    }
    
    private var releaseNotesArg: String? {
        guard !releaseNotes.isEmpty else {
            return nil
        }
        return escape(key: "release_notes", value: releaseNotes)
    }
    
    private var resetGitArg: String? {
        guard resetGit != defaultParameters.resetGit else {
            return nil
        }
        return "reset_git:\(resetGit)"
    }
    
    private var pushOnGitMessageArg: String? {
        guard pushOnGitMessage != defaultParameters.pushOnGitMessage else {
            return nil
        }
        return "push_commit:\(pushOnGitMessage)"
    }
    
    private var pushOnGitTagArg: String? {
        guard pushOnGitTag != defaultParameters.pushOnGitTag else {
            return nil
        }
        return "push_tag:\(pushOnGitTag)"
    }
    
    private var makeGitBranchArg: String? {
        guard makeGitBranch != defaultParameters.makeGitBranch else {
            return nil
        }
        return "make_git_branch:\(makeGitBranch)"
    }
    
    private var useBitbucketArg: String? {
        guard makeBitbucketPr != defaultParameters.makeBitbucketPr else {
            return nil
        }
        return "make_bitbucket_pr:\(makeBitbucketPr)"
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
        guard makeReleaseNotesFromJira != defaultParameters.useJiraReleaseNotes else {
            return nil
        }
        return "use_jira_release_notes:\(makeReleaseNotesFromJira)"
    }
    
    private var makeJiraReleaseArg: String? {
        guard makeJiraRelease != defaultParameters.makeJiraRelease else {
            return nil
        }
        return "make_jira_release:\(makeJiraRelease)"
    }
    
    private var sprintArg: String? {
        guard sprint != .none else {
            return nil
        }
        return "sprint:\(sprint.id)"
    }
    
    private var updateJiraTicketsArg: String? {
        guard updateJiraTickets != defaultParameters.updateJiraTickets else {
            return nil
        }
        return "update_jira_tickets:\(updateJiraTickets)"
    }
    
    private var debugModeArg: String? {
        guard debugMode != defaultParameters.debugMode else {
            return nil
        }
        return "debug_mode:\(debugMode)"
    }
    
    var toArray: [String] {
        [
            xcodeArg,
            envArg,
            versionNumberArg,
            buildNumberArg,
            branchNameArg,
            gitTagArg,
            testersArg,
            releaseNotesArg,
            resetGitArg,
            pushOnGitMessageArg,
            pushOnGitTagArg,
            makeGitBranchArg,
            useBitbucketArg,
            uploadToFirebaseArg,
            useCrashlyticsArg,
            useDynatraceArg,
            notifySlackArg,
            makeJiraReleaseArg,
            sprintArg,
            updateJiraTicketsArg,
            makeReleaseNotesFromJiraArg,
            debugModeArg
        ].compactMap{ $0 }
    }
    
    private func escape(key: String, value: String) -> String {
        "\(key):\\\"\(value)\\\""
    }
}

extension CommandExecuting {
    func fastlaneDeploy(arguments: FastlaneDeployArguments) throws -> String {
        try fastlane(command: .deploy, arguments: arguments)
    }
}

extension FastlaneDeployArguments {
    struct DefaultParameters {
        
        let xcode: String
        let resetGit: Bool
        let pushOnGitMessage: Bool
        let pushOnGitTag: Bool
        let makeGitBranch: Bool
        let makeBitbucketPr: Bool
        let uploadToFirebase: Bool
        let useCrashlytics: Bool
        let useDynatrace: Bool
        let useSlack: Bool
        let useJiraReleaseNotes: Bool
        let makeJiraRelease: Bool
        let updateJiraTickets: Bool
        let debugMode: Bool
        
        init() {
            let path = projectFastlanePathComponent + "/" + ".default_parameters"
            
            let values = (try? String.contentsOfFileSeparatedByNewLine(path: path)) ?? []
            
            var xcode: String?
            var resetGit: Bool?
            var pushOnGitMessage: Bool?
            var pushOnGitTag: Bool?
            var makeGitBranch: Bool?
            var makeBitbucketPr: Bool?
            var uploadToFirebase: Bool?
            var useCrashlytics: Bool?
            var useDynatrace: Bool?
            var useSlack: Bool?
            var useJiraReleaseNotes: Bool?
            var makeJiraRelease: Bool?
            var updateJiraTickets: Bool?
            var debugMode: Bool?
            
            func purge(value: String, parameter: Parameter) -> String? {
                value.purge(using: parameter.key)
            }
            
            values.forEach {
                if let value = purge(value: $0, parameter: .xcode) {
                    xcode = value
                } else if let value = purge(value: $0, parameter: .pushOnGitMessage) {
                    pushOnGitMessage = Bool(value)
                } else if let value = purge(value: $0, parameter: .pushOnGitTag) {
                    pushOnGitTag = Bool(value)
                } else if let value = purge(value: $0, parameter: .resetGit) {
                    resetGit = Bool(value)
                } else if let value = purge(value: $0, parameter: .makeGitBranch) {
                    makeGitBranch = Bool(value)
                } else if let value = purge(value: $0, parameter: .makeBitbucketPr) {
                    makeBitbucketPr = Bool(value)
                } else if let value = purge(value: $0, parameter: .uploadToFirebase) {
                    uploadToFirebase = Bool(value)
                } else if let value = purge(value: $0, parameter: .useCrashlytics) {
                    useCrashlytics = Bool(value)
                } else if let value = purge(value: $0, parameter: .useDynatrace) {
                    useDynatrace = Bool(value)
                } else if let value = purge(value: $0, parameter: .useSlack) {
                    useSlack = Bool(value)
                } else if let value = purge(value: $0, parameter: .useJiraReleaseNotes) {
                    useJiraReleaseNotes = Bool(value)
                } else if let value = purge(value: $0, parameter: .makeJiraRelease) {
                    makeJiraRelease = Bool(value)
                } else if let value = purge(value: $0, parameter: .updateJiraTickets) {
                    updateJiraTickets = Bool(value)
                } else if let value = purge(value: $0, parameter: .debugMode) {
                    debugMode = Bool(value)
                }
            }
            
            self.xcode = xcode ?? ""
            self.resetGit = resetGit ?? false
            self.pushOnGitMessage = pushOnGitMessage ?? false
            self.pushOnGitTag = pushOnGitTag ?? false
            self.makeGitBranch = makeGitBranch ?? false
            self.makeBitbucketPr = makeBitbucketPr ?? false
            self.uploadToFirebase = uploadToFirebase ?? false
            self.useCrashlytics = useCrashlytics ?? false
            self.useDynatrace = useDynatrace ?? false
            self.useSlack = useSlack ?? false
            self.useJiraReleaseNotes = useJiraReleaseNotes ?? false
            self.makeJiraRelease = makeJiraRelease ?? false
            self.updateJiraTickets = updateJiraTickets ?? false
            self.debugMode = debugMode ?? false
        }
    }
}

extension FastlaneDeployArguments.DefaultParameters {
    enum Parameter {
        
        case xcode
        case resetGit
        case pushOnGitMessage
        case pushOnGitTag
        case makeGitBranch
        case makeBitbucketPr
        case uploadToFirebase
        case useCrashlytics
        case useDynatrace
        case useSlack
        case useJiraReleaseNotes
        case makeJiraRelease
        case updateJiraTickets
        case debugMode
        
        var key: String {
            switch self {
            case .xcode:
                "XCODE"
            case .resetGit:
                "RESET_GIT"
            case .pushOnGitMessage:
                "PUSH_MESSAGE"
            case .pushOnGitTag:
                "PUSH_TAG"
            case .makeGitBranch:
                "MAKE_GIT_BRANCH"
            case .makeBitbucketPr:
                "MAKE_BITBUCKET_PR"
            case .uploadToFirebase:
                "UPLOAD_TO_FIREBASE"
            case .useCrashlytics:
                "USE_CRASHLYTICS"
            case .useDynatrace:
                "USE_DYNATRACE"
            case .useSlack:
                "USE_SLACK"
            case .useJiraReleaseNotes:
                "USE_JIRA_RELEASE_NOTES"
            case .makeJiraRelease:
                "MAKE_JIRA_RELEASE"
            case .updateJiraTickets:
                "UPDATE_JIRA_TICKETS"
            case .debugMode:
                "DEBUG_MODE"
            }
        }
    }
}
