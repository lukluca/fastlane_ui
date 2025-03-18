//
//  Wizard.swift
//  Fastlane-UI
//
//  Created by softwave on 15/11/23.
//

import SwiftUI
import Combine

private let USERNAME = "USERNAME"
private let TOKEN = "TOKEN"
private let TOKEN_PR_W = "TOKEN_PR_W"

struct Wizard: View {
    
    @ObservedObject private var currentStep: Step = .initial
    
    @State private var isBackButtonDisabled = true
    @State private var isNextButtonDisabled = true
    
    @State private var errorText = ""
    
    @State private var isCompleted = false
    
    @ObservedObject private var stepCompleted = StepCompleted()
    
    private var bag = [AnyCancellable]()
    
    var body: some View {
        VStack(spacing: 10) {
            
            Text("Wizard")
            
            ScrollView{
                HStack(spacing: 0){
                    ForEach(Step.Kind.allCases) {
                        StepCircleView(text: "\($0.rawValue + 1)",
                                       isLast: $0.isLast,
                                       isDone: ($0.isLast && stepCompleted.isCompleted) ? true : $0.rawValue < stepCompleted.count )
                    }
                }
            }
            .frame(height: 40)
            .padding()
            
            StepContent(current: $currentStep.kind,
                        errorText: $errorText)
                .padding()
            
            HStack(spacing: 30) {
                
                Button {
                    if let kind = Step.Kind(rawValue: currentStep.kind.rawValue - 1) {
                        currentStep.kind = kind
                    } else {
                        isBackButtonDisabled = true
                    }
                } label: {
                    Image(systemName: "arrowshape.backward")
                        .resizable()
                        .scaledToFit()
                        .imageScale(.large)
                        .frame(height: 50)
                }
                .disabled(isBackButtonDisabled)
                
                if isCompleted && currentStep.kind.isLast {
                    Button {
                        Defaults.shared.showWizard = false
                    } label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .scaledToFit()
                            .imageScale(.large)
                            .frame(height: 50)
                    }
                } else {
                    Button {
                        
                        @MainActor
                        func goToNextStep() {
                            isBackButtonDisabled = false
                            if let kind = Step.Kind(rawValue: currentStep.kind.rawValue + 1) {
                                
                                currentStep.chooseState()
                                
                                currentStep.kind = kind
                            } else {
                                isNextButtonDisabled = true
                            }
                        }
                        
                        let error = currentStep.kind.error
                        errorText = error
                        
                        if !error.isEmpty {
                            isNextButtonDisabled = true
                        } else {
                            goToNextStep()
                        }
                    } label: {
                        Image(systemName: "arrowshape.forward")
                            .resizable()
                            .scaledToFit()
                            .imageScale(.large)
                            .frame(height: 50)
                    }
                    .disabled(isNextButtonDisabled)
                }
            }
            .onAppear {
                currentStep.setInitialIfNeeded()
                
                isNextButtonDisabled = !currentStep.isDone
                isBackButtonDisabled = currentStep.kind.rawValue == 0
                isCompleted = stepCompleted.isCompleted
            }.onChange(of: currentStep.kind) { newValue in
                errorText = ""
                isBackButtonDisabled = newValue.rawValue == 0
                isNextButtonDisabled = newValue.rawValue == (Step.Kind.allCases.count - 1)
            }
            .onReceive(currentStep.$isDone) { value in
                isNextButtonDisabled = !value
            }
            .onChange(of: stepCompleted.isCompleted) { newValue in
                isCompleted = newValue
            }
        }
    }
}

extension Wizard {
    struct StepCircleView: View {
        
        let text: String
        let isLast: Bool
        let isDone: Bool
        
        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                
                ZStack {
                    Circle()
                        .stroke(isDone ? .blue : .gray, lineWidth: 2)
                    
                    Text(text)
                }
                .frame(width: 30, height: 30)
                .padding(5)
                
                if !isLast {
                    Rectangle().fill(isDone ? .blue : .gray).frame(width: 33, height: 1, alignment: .center)
                }
            }
        }
    }
}

extension Wizard {
    struct StepContent: View {
        
        @Binding var current: Step.Kind
        @Binding var errorText: String

        var body: some View {
            switch current {
            case .projectFolder:
                ProjectFolderItem(errorText: $errorText)
            case .git:
                GitItem(errorText: $errorText)
            case .bitbucket:
                BitbucketItem(errorText: $errorText)
            case .firebase:
                FirebaseItem(errorText: $errorText)
            case .dynatrace:
                DynatraceItem(errorText: $errorText)
            case .jira:
                JiraItem(errorText: $errorText)
            case .slack:
                SlackItem(errorText: $errorText)
            case .teams:
                TeamsItem(errorText: $errorText)
            case .completed:
                CompletedItem()
            }
        }
    }
}

extension Wizard {
    struct ProjectFolderItem: View {
        
        @Default(\.projectFolder) private var projectFolder: String
        
        @Binding var errorText: String
        
        var body: some View {
            VStack(spacing: 20) {
                ProjectFolderView(projectFolder: $projectFolder)
                    .padding(.horizontal, 20)
                
                Text("This is the folder on your mac where the git froject is stored. Must not be empty.")
                
                Text(errorText)
                    .foregroundStyle(.red)
            }
        }
    }
    
    struct GitItem: View {
        
        @State private var isChecked = false
        
        @Binding var errorText: String
        
        @Default(\.useGit) private var useGit: Bool
      
        var body: some View {
            VStack(spacing: 20) {
                Toggle(isOn: $isChecked) {
                    Text("Enable Git")
                }
                .toggleStyle(.checkbox)
                
                Text("If you wish to use Git, inside the project folder must be inited git.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text(errorText)
                    .foregroundStyle(.red)
                
            }.onAppear {
                isChecked = useGit
            }.onChange(of: isChecked) { newValue in
                useGit = newValue
                Defaults.shared.isGitChoosen = true
            }
        }
    }
    
    struct BitbucketItem: View {
        
        @State private var isChecked = false
        
        @Binding var errorText: String
        
        @Default(\.makeBitbucketPr) private var makeBitbucketPr: Bool
        @Default(\.bitbucketCredentialsFolder) private var bitbucketCredentialsFolder: String
      
        var body: some View {
            VStack(spacing: 20) {
                Toggle(isOn: $isChecked) {
                    Text("Enable Bitbucket")
                }
                .toggleStyle(.checkbox)
                
                BitbucketCredentialsFoldetView(credentialsFolder: $bitbucketCredentialsFolder)
                    .opacity(isChecked ? 1 : 0.5)
                    .allowsHitTesting(isChecked)
                    .padding(.horizontal, 20)
                
                Text("If you wish to manage pull request using Bitbucket, please fill the folder where the credentials are stored. Must not be empty.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text("Inside this folder there must be a file named '\(credentialsPathComponent)' of this structure\n\n\(USERNAME)=\"BITBUCKET_USERNAME\" \n\(TOKEN_PR_W)=\"BITBUCKET_TOKEN\"\n\nPlease replace BITBUCKET_USERNAME and BITBUCKET_TOKEN with your credentials!")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text("""
                     Inside the 'fastlane/.bitbucket' project folder there must be a 'config' file of this structure\n\nCOMPANY_HOST_NAME=\"YOUR_COMPANY\"\n
                     REPOSITORY_NAME=\"YOUR_REPO\"\n
                     TITLE=\"YOUR_TITLE"\n
                     DESCRIPTION=\"YOUR_DESCRIPTION"\n
                     SOURCE_BRANCH=\"YOUR_SOURCE"\n
                     DESTINATION_BRANCH=\"YOUR_DESTINATION"\n\nPlease replace values with valid one!
                    """)
                    .opacity(isChecked ? 1 : 0.5)
                
                Text("You can configure Bitbucket from the Bitbucket tab later.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text(errorText)
                    .foregroundStyle(.red)
                
            }.onAppear {
                isChecked = makeBitbucketPr
            }.onChange(of: isChecked) { newValue in
                makeBitbucketPr = newValue
                Defaults.shared.isBitBucketChoosen = true
            }
        }
    }
    
    struct FirebaseItem: View {
        
        @State private var isChecked = false
        
        @Binding var errorText: String
        
        @Default(\.useFirebase) private var useFirebase: Bool
      
        var body: some View {
            VStack(spacing: 20) {
                Toggle(isOn: $isChecked) {
                    Text("Enable Firebase")
                }
                .toggleStyle(.checkbox)
                
                Text("If you wish to use Firebase, inside the fastlane folder there must be a 'google-creds.json' file filled with the Firebase project data.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text(errorText)
                    .foregroundStyle(.red)
                
            }.onAppear {
                isChecked = useFirebase
            }.onChange(of: isChecked) { newValue in
                useFirebase = newValue
                Defaults.shared.isFirebaseChoosen = true
            }
        }
    }
    
    struct DynatraceItem: View {
        
        @State private var isChecked = false
        
        @Binding var errorText: String
        
        @Default(\.useDynatrace) private var useDynatrace: Bool
      
        var body: some View {
            VStack(spacing: 20) {
                Toggle(isOn: $isChecked) {
                    Text("Enable Dynatrace")
                }
                .toggleStyle(.checkbox)
                
                Text("If you wish to use Dynatrace, inside the .dynatrace subfolder of fastlane folder there must be a 'config' file filled with the Dynatrace project data.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text(errorText)
                    .foregroundStyle(.red)
                
            }.onAppear {
                isChecked = useDynatrace
            }.onChange(of: isChecked) { newValue in
                useDynatrace = newValue
                Defaults.shared.isDynatraceChoosen = true
            }
        }
    }
    
    struct JiraItem: View {
        
        @State private var isChecked = false
        
        @Binding var errorText: String
        
        @Default(\.useJira) private var useJira: Bool
        @Default(\.jiraCredentialsFolder) private var jiraCredentialsFolder: String
        
        var body: some View {
            VStack(spacing: 20) {
                Toggle(isOn: $isChecked) {
                    Text("Enable Jira")
                }
                .toggleStyle(.checkbox)
                
                JiraCredentialsFoldetView(credentialsFolder: $jiraCredentialsFolder)
                    .opacity(isChecked ? 1 : 0.5)
                    .allowsHitTesting(isChecked)
                    .padding(.horizontal, 20)
                
                Text("If you wish to make release notes from Jira, please fill the folder where the credentials are stored. Must not be empty.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text("Inside this folder there must be a file named '\(credentialsPathComponent)' of this structure\n\n\(USERNAME)=\"JIRA_USERNAME\" \n\(TOKEN)=\"JIRA_TOKEN\"\n\nPlease replace JIRA_USERNAME and JIRA_TOKEN with your credentials!")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text("Inside the 'fastlane/.jira' project folder there must be a 'host' file of this structure\n\nURL=\"JIRA_URL\" \nPROJECT=\"JIRA_PROJECT_NAME\"\n\nPlease replace JIRA_URL and JIRA_PROJECT_NAME with valid value!")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text("You can configure the status of the ticket to show inside release note from the Jira tab later.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text(errorText)
                    .foregroundStyle(.red)
                
            }.onAppear {
                isChecked = useJira
            }.onChange(of: isChecked) { newValue in
                useJira = newValue
                Defaults.shared.isJiraChoosen = true
            }
        }
    }
    
    struct SlackItem: View {
        
        @State private var isChecked = false
        
        @Binding var errorText: String
        
        @Default(\.useSlack) private var useSlack: Bool
        
        var body: some View {
            VStack(spacing: 20) {
                Toggle(isOn: $isChecked) {
                    Text("Enable Slack")
                }
                .toggleStyle(.checkbox)
                
                Text("If you wish to notify Slack about build results, please fill up '.config' file with your Slack token. This file must be stored inside 'fastlane/.slack' project folder.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text(errorText)
                    .foregroundStyle(.red)
                
            }.onAppear {
                isChecked = useSlack
            }.onChange(of: isChecked) { newValue in
                useSlack = newValue
                Defaults.shared.isSlackChoosen = true
            }
        }
    }
    
    struct TeamsItem: View {
        
        @State private var isChecked = false
        
        @Binding var errorText: String
        
        @Default(\.useTeams) private var useTeams: Bool
        
        var body: some View {
            VStack(spacing: 20) {
                Toggle(isOn: $isChecked) {
                    Text("Enable Teams")
                }
                .toggleStyle(.checkbox)
                
                Text("If you wish to notify Teams about build results, please fill up '.config' file with your Teams token. This file must be stored inside 'fastlane/.teams' project folder.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text(errorText)
                    .foregroundStyle(.red)
                
            }.onAppear {
                isChecked = useTeams
            }.onChange(of: isChecked) { newValue in
                useTeams = newValue
                Defaults.shared.isTeamsChoosen = true
            }
        }
    }
    
    struct CompletedItem: View {
        
        var body: some View {
            Text("Now the wizard is completed, you can close this window!")
        }
    }
}

extension Wizard {
    
    @MainActor
    final class Step {
        
        @Published var isDone = false
        
        private var state: StepState?
        
        private var bag = [AnyCancellable]()
        
        @Published var kind: Kind {
            didSet {
                state = nil
                bag.removeAll()
                bindIsDone()
            }
        }
        
        init(kind: Kind) {
            self.kind = kind
            
            bindIsDone()
        }
        
        func setInitialIfNeeded() {
            let initial = Kind.projectFolder
            guard kind != initial else {
                return
            }
            
            kind = initial
        }
        
        func chooseState() {
            state?.choose()
        }
        
        private func bindIsDone() {
            let state = kind.stepState
            state?.$isDone
                .assign(to: \.isDone, on: self)
                .store(in: &bag)
            self.state = state
        }
    }
}

extension Wizard.Step {
    @MainActor
    enum Kind: Int {
        case projectFolder = 0
        case git
        case bitbucket
        case firebase
        case dynatrace
        case jira
        case slack
        case teams
        case completed
        
        var isLast: Bool {
            self == .completed
        }
    }
}

extension Wizard.Step.Kind: Hashable {}

extension Wizard.Step.Kind: @preconcurrency Identifiable {
    var id: Int {
        rawValue
    }
}

extension Wizard.Step.Kind: CaseIterable {}

extension Wizard.Step.Kind {
    var error: String {
        switch self {
        case .projectFolder:
            do {
                if try ProjectFolder.containsProjectFile() {
                    return ""
                } else {
                    return "The folder does not contain a xcodeproj file!"
                }
            } catch {
                return error.localizedDescription
            }
        case .git:
            do {
                if try GitFolder.validate() {
                    return ""
                } else {
                    return "The folder does not contain a git repo inited!"
                }
            } catch {
                return error.localizedDescription
            }
        case .bitbucket:
            do {
                if try BitbucketFolder.validate() {
                    return ""
                } else {
                    return "The folder does not contain a formatted credentials file!"
                }
            } catch {
                return error.localizedDescription
            }
            
        case .firebase:
            do {
                if try FirebaseFolder.validate() {
                    return ""
                } else {
                    return "The 'fastlane 'folder does not contain a google credentials file!"
                }
            } catch {
                return error.localizedDescription
            }
        case .dynatrace:
            do {
                if try DynatraceFolder.validate() {
                    return ""
                } else {
                    return "The '.dynatrace 'folder does not contain a config file!"
                }
            } catch {
                return error.localizedDescription
            }
        case .jira:
            do {
                if try JiraFolder.validate() {
                    return ""
                } else {
                    return "The folder does not contain a formatted credentials file!"
                }
            } catch {
                return error.localizedDescription
            }
        case .slack:
            do {
                if try SlackFolder.validate() {
                    return ""
                } else {
                    return "The folder does not contain a formatted config file!"
                }
            } catch {
                return error.localizedDescription
            }
        case .teams:
            do {
                if try SlackFolder.validate() {
                    return ""
                } else {
                    return "The folder does not contain a formatted config file!"
                }
            } catch {
                return error.localizedDescription
            }
        case .completed:
            return ""
        }
    }
    
    var stepState: StepState? {
        switch self {
        case .projectFolder:
            ProjectFolderStepState()
        case .git:
            GitFolderStepState()
        case .bitbucket:
            BitbucketFolderStepState()
        case .firebase:
            FirebaseFolderStepState()
        case .dynatrace:
            DynatraceFolderStepState()
        case .jira:
            JiraFolderStepState()
        case .slack:
            SlackFolderStepState()
        case .teams:
            TeamsFolderStepState()
        case .completed:
            nil
        }
    }
}

extension Wizard.Step: ObservableObject {}

extension Wizard.Step {
    static let initial = Wizard.Step(kind: .projectFolder)
}

extension Wizard.Step: @preconcurrency Equatable {
    static func == (lhs: Wizard.Step, rhs: Wizard.Step) -> Bool {
        lhs.kind == rhs.kind
    }
}

extension Wizard.Step: @preconcurrency Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
    }
}

extension Wizard.Step: @preconcurrency Identifiable {
    var id: Kind {
        kind
    }
}

@MainActor
class StepState: ObservableObject {
    @Published var isDone = false
    
    func choose() {}
}

@MainActor
final class ProjectFolderStepState: StepState {
    
    private var bag = [AnyCancellable]()
    
    override init() {
        super.init()
        
        isDone = ProjectFolder.validatePath()
        
        Defaults.shared.objectWillChange.map {
            Defaults.shared.projectFolder
        }
        .removeDuplicates()
        .map {
            ProjectFolder.isValid($0)
        }
        .assign(to: \.isDone, on: self)
        .store(in: &bag)
    }
}

@MainActor
final class GitFolderStepState: StepState {
    
    private var bag = [AnyCancellable]()
    
    override init() {
        super.init()
        
        isDone = GitFolder.validateEnabledPath()
        
        let isEnabled = Defaults.shared.objectWillChange.map {
            Defaults.shared.useGit
        }
            .removeDuplicates()
            .filter { $0 }
        
        let isPathValid = Defaults.shared.objectWillChange.map {
            Defaults.shared.projectFolder
        }
            .removeDuplicates()
            .map { $0 != "" }
            .filter { $0 }
        
        isEnabled.merge(with: isPathValid)
            .assign(to: \.isDone, on: self)
            .store(in: &bag)
    }
    
    override func choose() {
        Defaults.shared.isGitChoosen = true
    }
}

@MainActor
final class BitbucketFolderStepState: StepState {
    
    private var bag = [AnyCancellable]()
    
    override init() {
        super.init()
        
        isDone = BitbucketFolder.validateEnabledPath()
        
        let isEnabled = Defaults.shared.objectWillChange.map {
            Defaults.shared.makeBitbucketPr
        }
            .removeDuplicates()
            .filter { $0 }
        
        let isPathValid = Defaults.shared.objectWillChange.map {
            Defaults.shared.bitbucketCredentialsFolder
        }
            .removeDuplicates()
            .map { $0 != "" }
            .filter { $0 }
        
        isEnabled.merge(with: isPathValid)
            .assign(to: \.isDone, on: self)
            .store(in: &bag)
    }
    
    override func choose() {
        Defaults.shared.isBitBucketChoosen = true
    }
}

@MainActor
final class FirebaseFolderStepState: StepState {
    
    private var bag = [AnyCancellable]()
    
    override init() {
        super.init()
        
        isDone = FirebaseFolder.validateEnabledPath()
        
        let isEnabled = Defaults.shared.objectWillChange.map {
            Defaults.shared.useFirebase
        }
            .removeDuplicates()
            .filter { $0 }
        
        let isPathValid = Defaults.shared.objectWillChange.map {
            Defaults.shared.projectFolder
        }
            .removeDuplicates()
            .map { $0 != "" }
            .filter { $0 }
        
        isEnabled.merge(with: isPathValid)
            .assign(to: \.isDone, on: self)
            .store(in: &bag)
    }
    
    override func choose() {
        Defaults.shared.isFirebaseChoosen = true
    }
}

@MainActor
final class DynatraceFolderStepState: StepState {
    
    private var bag = [AnyCancellable]()
    
    override init() {
        super.init()
        
        isDone = DynatraceFolder.validateEnabledPath()
        
        let isEnabled = Defaults.shared.objectWillChange.map {
            Defaults.shared.useDynatrace
        }
            .removeDuplicates()
            .filter { $0 }
        
        let isPathValid = Defaults.shared.objectWillChange.map {
            Defaults.shared.projectFolder
        }
            .removeDuplicates()
            .map { $0 != "" }
            .filter { $0 }
        
        isEnabled.merge(with: isPathValid)
            .assign(to: \.isDone, on: self)
            .store(in: &bag)
    }
    
    override func choose() {
        Defaults.shared.isDynatraceChoosen = true
    }
}

@MainActor
final class JiraFolderStepState: StepState {
    
    private var bag = [AnyCancellable]()
    
    override init() {
        super.init()
        
        isDone = JiraFolder.validateEnabledPath()
        
        let isEnabled = Defaults.shared.objectWillChange.map {
            Defaults.shared.useJira
        }
            .removeDuplicates()
            .filter { $0 }
        
        let isPathValid = Defaults.shared.objectWillChange.map {
            Defaults.shared.jiraCredentialsFolder
        }
            .removeDuplicates()
            .map { $0 != "" }
            .filter { $0 }
        
        isEnabled.merge(with: isPathValid)
            .assign(to: \.isDone, on: self)
            .store(in: &bag)
    }
    
    override func choose() {
        Defaults.shared.isJiraChoosen = true
    }
}

@MainActor
final class SlackFolderStepState: StepState {
    
    private var bag = [AnyCancellable]()
    
    override init() {
        super.init()
        
        isDone = SlackFolder.validateEnabledPath()
        
        let isEnabled = Defaults.shared.objectWillChange.map {
            Defaults.shared.useSlack
        }
            .removeDuplicates()
            .filter { $0 }
        
        let isPathValid = Defaults.shared.objectWillChange.map {
            Defaults.shared.projectFolder
        }
            .removeDuplicates()
            .map { $0 != "" }
            .filter { $0 }
        
        isEnabled.merge(with: isPathValid)
            .assign(to: \.isDone, on: self)
            .store(in: &bag)
    }
    
    override func choose() {
        Defaults.shared.isSlackChoosen = true
    }
}

@MainActor
final class TeamsFolderStepState: StepState {
    
    private var bag = [AnyCancellable]()
    
    override init() {
        super.init()
        
        isDone = TeamsFolder.validateEnabledPath()
        
        let isEnabled = Defaults.shared.objectWillChange.map {
            Defaults.shared.useTeams
        }
            .removeDuplicates()
            .filter { $0 }
        
        let isPathValid = Defaults.shared.objectWillChange.map {
            Defaults.shared.projectFolder
        }
            .removeDuplicates()
            .map { $0 != "" }
            .filter { $0 }
        
        isEnabled.merge(with: isPathValid)
            .assign(to: \.isDone, on: self)
            .store(in: &bag)
    }
    
    override func choose() {
        Defaults.shared.isTeamsChoosen = true
    }
}

@MainActor
private final class StepCompleted: ObservableObject {
    
    @Published var isCompleted = false
    
    @Published var count = 0
    
    private var bag = [AnyCancellable]()
    
    private let project = ProjectFolderStepState()
    private lazy var stepStates: [StepState] = {
        Wizard.Step.Kind.allCases.compactMap {
            $0.stepState
        }
    }()
    
    init() {
        
        let isDone = project.$isDone
        var merge: Publishers.MergeMany<Published<Bool>.Publisher>?
        
        stepStates.forEach { state in
            if let previous = merge {
                merge = previous.merge(with: state.$isDone)
            } else {
                merge = isDone.merge(with: state.$isDone)
            }
        }
        
        if let merge {
            merge.filter { $0 }
                .count()
                .removeDuplicates()
                .assign(to: \.count, on: self)
                .store(in: &bag)
        }
         
        $count
            .map { $0 == (Wizard.Step.Kind.allCases.count - 1) }
            .assign(to: \.isCompleted, on: self)
            .store(in: &bag)
        
        let validateValues = validate()
        
        if validateValues.first == false {
            count = 0
        } else {
            count = validate().filter { $0 }.count
        }
    }
    
    func validate() -> [Bool] {
        Wizard.Step.Kind.allCases.compactMap {
            switch $0 {
            case .projectFolder:
                (try? ProjectFolder.validate()) ?? false
            case .git:
                (try? GitFolder.validateStep()) ?? false
            case .bitbucket:
                (try? BitbucketFolder.validateStep()) ?? false
            case .firebase:
                (try? FirebaseFolder.validateStep()) ?? false
            case .dynatrace:
                (try? DynatraceFolder.validateStep()) ?? false
            case .jira:
                (try? JiraFolder.validateStep()) ?? false
            case .slack:
                (try? SlackFolder.validateStep()) ?? false
            case .teams:
                (try? TeamsFolder.validateStep()) ?? false
            case .completed:
                nil
            }
        }
    }
}

@MainActor
private enum ProjectFolder {
    
    static func validate() throws -> Bool {
        try validatePath() && containsProjectFile()
    }
    
    static func validatePath() -> Bool {
        isValid(Defaults.shared.projectFolder)
    }
    
    static func isValid(_ string: String) -> Bool {
        string != ""
    }
    
    static func containsProjectFile() throws -> Bool {
        let path = Defaults.shared.projectFolder
        return try FileManager.default.contentsOfDirectory(atPath: path).contains { $0.hasSuffix(".xcodeproj") }
    }
}

@MainActor
private enum GitFolder {
    
    static func validate() throws -> Bool {
        guard Defaults.shared.isGitChoosen else {
            return true
        }
        return try privateValidate()
    }
    
    static func validateStep() throws -> Bool {
        guard Defaults.shared.isGitChoosen else {
            return false
        }
        return try privateValidate()
    }
    
    private static func privateValidate() throws -> Bool {
        guard Defaults.shared.useGit else {
            return true
        }
        return try validatePath() && containsGitRepo()
    }
    
    static func validateEnabledPath() -> Bool {
        guard Defaults.shared.useGit else {
            return true
        }
        return ProjectFolder.validatePath()
    }
    
    private static func validatePath() -> Bool {
        ProjectFolder.validatePath()
    }
    
    static func containsGitRepo() throws -> Bool {
        let path = Defaults.shared.projectFolder
        return try FileManager.default.contentsOfDirectory(atPath: path).contains { $0 == gitPathComponent }
    }
}

@MainActor
private enum BitbucketFolder {
    
    static func validate() throws -> Bool {
        guard Defaults.shared.isBitBucketChoosen else {
            return true
        }
        return try privateValidate()
    }
    
    static func validateStep() throws -> Bool {
        guard Defaults.shared.isBitBucketChoosen else {
            return false
        }
        
        return try privateValidate()
    }
    
    private static func privateValidate() throws -> Bool {
        guard Defaults.shared.makeBitbucketPr else {
            return true
        }
        
        return try validatePath() && areCredentialsPresent()
    }
    
    static func validateEnabledPath() -> Bool {
        guard Defaults.shared.makeBitbucketPr else {
            return true
        }
        return validatePath()
    }
    
    private static func validatePath() -> Bool {
        Defaults.shared.bitbucketCredentialsFolder != ""
    }
    
    static func areCredentialsPresent() throws -> Bool {
        let path = Defaults.shared.bitbucketCredentialsFolder
    
        let values = try String(contentsOfFile: path + "/" + credentialsPathComponent).split(separator: "\n")
        
        if values.count >= 2 {
            let first = values[0]
            
            let usernameKey = "\(USERNAME)="
            
            if first.starts(with: usernameKey) {
                
                let tail = first.replacingOccurrences(of: usernameKey, with: "")
                
                if tail.count > 2 {
                    let second = values[1]
                    
                    let tokenKey = "\(TOKEN_PR_W)="
                    
                    if second.starts(with: tokenKey) {
                        
                        let tail = second.replacingOccurrences(of: tokenKey, with: "")
                        
                        if tail.count > 2 {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
}

@MainActor
private enum FirebaseFolder {
    
    static func validate() throws -> Bool {
        guard Defaults.shared.isFirebaseChoosen else {
            return true
        }
        return try privateValidate()
    }
    
    static func validateStep() throws -> Bool {
        guard Defaults.shared.isFirebaseChoosen else {
            return false
        }
        return try privateValidate()
    }
    
    private static func privateValidate() throws -> Bool {
        guard Defaults.shared.useFirebase else {
            return true
        }
        return try validatePath() && containsGoogleCredentials()
    }
    
    static func validateEnabledPath() -> Bool {
        guard Defaults.shared.useFirebase else {
            return true
        }
        return validatePath()
    }
    
    private static func validatePath() -> Bool {
        ProjectFolder.validatePath()
    }
    
    static func containsGoogleCredentials() throws -> Bool {
        let path = projectFastlanePathComponent
        return try FileManager.default.contentsOfDirectory(atPath: path).contains { $0 == "google-creds.json" }
    }
}

@MainActor
private enum DynatraceFolder {
    
    static func validate() throws -> Bool {
        guard Defaults.shared.isDynatraceChoosen else {
            return true
        }
        return try privateValidate()
    }
    
    static func validateStep() throws -> Bool {
        guard Defaults.shared.isDynatraceChoosen else {
            return false
        }
        return try privateValidate()
    }
    
    private static func privateValidate() throws -> Bool {
        guard Defaults.shared.useDynatrace else {
            return true
        }
        return try validatePath() && containsConfig()
    }
    
    static func validateEnabledPath() -> Bool {
        guard Defaults.shared.useDynatrace else {
            return true
        }
        return validatePath()
    }
    
    private static func validatePath() -> Bool {
        ProjectFolder.validatePath()
    }
    
    static func containsConfig() throws -> Bool {
        let path = Defaults.shared.projectFolder + "/" + dynatracePathComponent
        return try FileManager.default.contentsOfDirectory(atPath: path).contains { $0 == "config" }
    }
}

@MainActor
private enum JiraFolder {
    
    static func validate() throws -> Bool {
        guard Defaults.shared.isJiraChoosen else {
            return true
        }
        return try privateValidate()
    }
    
    static func validateStep() throws -> Bool {
        guard Defaults.shared.isJiraChoosen else {
            return false
        }
        return try privateValidate()
    }
    
    private static func privateValidate() throws -> Bool {
        guard Defaults.shared.useJira else {
            return true
        }
        return try validatePath() && areCredentialsPresent()
    }
    
    static func validateEnabledPath() -> Bool {
        guard Defaults.shared.useJira else {
            return true
        }
        return Defaults.shared.jiraCredentialsFolder != ""
    }
    
    private static func validatePath() -> Bool {
        Defaults.shared.jiraCredentialsFolder != ""
    }
    
    static func areCredentialsPresent() throws -> Bool {
        let path = Defaults.shared.jiraCredentialsFolder
    
        let values = try String(contentsOfFile: path + "/" + credentialsPathComponent).split(separator: "\n")
        
        if values.count >= 2 {
            let first = values[0]
            
            let usernameKey = "\(USERNAME)="
            
            if first.starts(with: "\(USERNAME)=") {
                
                let tail = first.replacingOccurrences(of: usernameKey, with: "")
                
                if tail.count > 2 {
                    let second = values[1]
                    
                    let tokenKey = "\(TOKEN)="
                    
                    if second.starts(with: tokenKey) {
                        
                        let tail = second.replacingOccurrences(of: tokenKey, with: "")
                        
                        if tail.count > 2 {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
}

@MainActor
private enum SlackFolder {
    
    static func validate() throws -> Bool {
        guard Defaults.shared.isSlackChoosen else {
            return true
        }
        return try privateValidate()
    }
    
    static func validateStep() throws -> Bool {
        guard Defaults.shared.isSlackChoosen else {
            return false
        }
        return try privateValidate()
    }
    
    private static func privateValidate() throws -> Bool {
        guard Defaults.shared.useSlack else {
            return true
        }
        return try validatePath() && containsCredentials()
    }
    
    static func validateEnabledPath() -> Bool {
        guard Defaults.shared.useSlack else {
            return true
        }
        return validatePath()
    }
    
    private static func validatePath() -> Bool {
        ProjectFolder.validatePath()
    }
    
    static func containsCredentials() throws -> Bool {
        let path = projectFastlanePathComponent + "/.slack"
        return try FileManager.default.contentsOfDirectory(atPath: path).contains { $0 == "config" }
    }
}

@MainActor
private enum TeamsFolder {
    
    static func validate() throws -> Bool {
        guard Defaults.shared.isTeamsChoosen else {
            return true
        }
        return try privateValidate()
    }
    
    static func validateStep() throws -> Bool {
        guard Defaults.shared.isTeamsChoosen else {
            return false
        }
        return try privateValidate()
    }
    
    private static func privateValidate() throws -> Bool {
        guard Defaults.shared.useTeams else {
            return true
        }
        return try validatePath() && containsCredentials()
    }
    
    static func validateEnabledPath() -> Bool {
        guard Defaults.shared.useTeams else {
            return true
        }
        return validatePath()
    }
    
    private static func validatePath() -> Bool {
        ProjectFolder.validatePath()
    }
    
    static func containsCredentials() throws -> Bool {
        let path = projectFastlanePathComponent + "/.teams"
        return try FileManager.default.contentsOfDirectory(atPath: path).contains { $0 == "config" }
    }
}
