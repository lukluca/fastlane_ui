//
//  Wizard.swift
//  Fastlane-UI
//
//  Created by softwave on 15/11/23.
//

import SwiftUI
import Combine

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
                        
                        func goToNextStep() {
                            isBackButtonDisabled = false
                            if let kind = Step.Kind(rawValue: currentStep.kind.rawValue + 1) {
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
            case .firebase:
                FirebaseItem(errorText: $errorText)
            case .dynatrace:
                DynatraceItem(errorText: $errorText)
            case .jira:
                JiraItem(errorText: $errorText)
            case .slack:
                SlackItem(errorText: $errorText)
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
                useGit = isChecked
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
                useFirebase = isChecked
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
                useDynatrace = isChecked
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
                
                Text("Inside this folder there must be a file named '\(credentialsPathComponent)' of this structure\n\nUSERNAME=\"JIRA_USERNAME\" \nTOKEN=\"JIRA_TOKEN\"\n\nPlease replace JIRA_USERNAME and JIRA_TOKEN with your credentials!")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text("Inside the 'fastlane/.jira' project folder there must be a host file of this structure\n\nURL=\"JIRA_URL\" \nPROJECT=\"JIRA_PROJECT_NAME\"\n\nPlease replace JIRA_URL and JIRA_PROJECT_NAME with valid value!")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text("You can configure the status of the ticket to show inside release note from the Jira tab later.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text(errorText)
                    .foregroundStyle(.red)
                
            }.onAppear {
                isChecked = useJira
            }.onChange(of: isChecked) { newValue in
                useJira = isChecked
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
                
                Text("If you wish to notify Slack about build results, please fill up '.slack_token' file with your Slack token. This file must be stored inside 'fastlane' project folder.")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text(errorText)
                    .foregroundStyle(.red)
                
            }.onAppear {
                isChecked = useSlack
            }.onChange(of: isChecked) { newValue in
                useSlack = isChecked
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
    
    final class Step {
        
        @Published var isDone = false
        
        private var state: Any?
        
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
        
        private func bindIsDone() {
            switch kind {
            case .projectFolder:
                let state = ProjectFolderStepState()
                state.$isDone
                    .assign(to: \.isDone, on: self)
                    .store(in: &bag)
                self.state = state
            case .git:
                let state = GitFolderStepState()
                state.$isDone
                    .assign(to: \.isDone, on: self)
                    .store(in: &bag)
                self.state = state
            case .firebase:
                let state = FirebaseFolderStepState()
                state.$isDone
                    .assign(to: \.isDone, on: self)
                    .store(in: &bag)
                self.state = state
            case .dynatrace:
                let state = DynatraceFolderStepState()
                state.$isDone
                    .assign(to: \.isDone, on: self)
                    .store(in: &bag)
                self.state = state
            case .jira:
                let state = JiraFolderStepState()
                state.$isDone
                    .assign(to: \.isDone, on: self)
                    .store(in: &bag)
                self.state = state
            case .slack:
                let state = SlackStepState()
                state.$isDone
                    .assign(to: \.isDone, on: self)
                    .store(in: &bag)
                self.state = state
              case .completed:
                break
            }
        }
    }
}

extension Wizard.Step {
    enum Kind: Int {
        case projectFolder = 0
        case git
        case firebase
        case dynatrace
        case jira
        case slack
        case completed
        
        var isLast: Bool {
            self == .completed
        }
    }
}

extension Wizard.Step.Kind: Hashable {}

extension Wizard.Step.Kind: Identifiable {
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
                    return "The folder does not contain a formatted credentials file"
                }
            } catch {
                return error.localizedDescription
            }
        case .slack:
            do {
                if try SlackFolder.validate() {
                    return ""
                } else {
                    return "The folder does not contain a formatted credentials file"
                }
            } catch {
                return error.localizedDescription
            }
        case .completed:
            return ""
        }
    }
}

extension Wizard.Step: ObservableObject {}

extension Wizard.Step {
    static let initial = Wizard.Step(kind: .projectFolder)
}

extension Wizard.Step: Equatable {
    static func == (lhs: Wizard.Step, rhs: Wizard.Step) -> Bool {
        lhs.kind == rhs.kind
    }
}

extension Wizard.Step: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
    }
}

extension Wizard.Step: Identifiable {
    var id: Kind {
        kind
    }
}

final class ProjectFolderStepState: ObservableObject {
    
    @Published var isDone = false
    
    private var bag = [AnyCancellable]()
    
    init() {
        
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

final class GitFolderStepState: ObservableObject {
    
    @Published var isDone = false
    
    private var bag = [AnyCancellable]()
    
    init() {
        
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
}

final class FirebaseFolderStepState: ObservableObject {
    
    @Published var isDone = false
    
    private var bag = [AnyCancellable]()
    
    init() {
        
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
}

final class DynatraceFolderStepState: ObservableObject {
    
    @Published var isDone = false
    
    private var bag = [AnyCancellable]()
    
    init() {
        
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
}

final class JiraFolderStepState: ObservableObject {
    
    @Published var isDone = false
    
    private var bag = [AnyCancellable]()
    
    init() {
        
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
}

final class SlackStepState: ObservableObject {
    
    @Published var isDone = false
    
    private var bag = [AnyCancellable]()
    
    init() {
        
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
}

private final class StepCompleted: ObservableObject {
    
    @Published var isCompleted = false
    
    @Published var count = 0
    
    private var bag = [AnyCancellable]()
    
    private let project = ProjectFolderStepState()
    private let jira = JiraFolderStepState()
    
    init() {
        
        project.$isDone
            .merge(with: jira.$isDone)
            .filter { $0 }
            .count()
            .removeDuplicates()
            .assign(to: \.count, on: self)
            .store(in: &bag)
        
        $count
            .map { $0 == (Wizard.Step.Kind.allCases.count - 1) }
            .assign(to: \.isCompleted, on: self)
            .store(in: &bag)
        
        count = validate().filter { $0 }.count
    }
    
    func validate() -> [Bool] {
        Wizard.Step.Kind.allCases.compactMap {
            switch $0 {
            case .projectFolder:
                return (try? ProjectFolder.validate()) ?? false
            case .git:
                return (try? GitFolder.validate()) ?? false
            case .firebase:
                return (try? FirebaseFolder.validate()) ?? false
            case .dynatrace:
                return (try? DynatraceFolder.validate()) ?? false
            case .jira:
                return (try? JiraFolder.validate()) ?? false
            case .slack:
                return (try? SlackFolder.validate()) ?? false
            case .completed:
                return nil
            }
        }
    }
}

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

private enum GitFolder {
    
    static func validate() throws -> Bool {
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

private enum FirebaseFolder {
    
    static func validate() throws -> Bool {
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
        let path = Defaults.shared.projectFolder + "/" + fastlanePathComponent
        return try FileManager.default.contentsOfDirectory(atPath: path).contains { $0 == "google-creds.json" }
    }
}

private enum DynatraceFolder {
    
    static func validate() throws -> Bool {
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
        let path = Defaults.shared.projectFolder + "/" + fastlanePathComponent + "/" + ".dynatrace"
        return try FileManager.default.contentsOfDirectory(atPath: path).contains { $0 == "config" }
    }
}

private enum SlackFolder {
    
    static func validate() throws -> Bool {
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
        let path = Defaults.shared.projectFolder + "/" + fastlanePathComponent
        return try FileManager.default.contentsOfDirectory(atPath: path).contains { $0 == ".slack_token" }
    }
}


private enum JiraFolder {
    
    static func validate() throws -> Bool {
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
            
            if first.starts(with: "USERNAME=") {
                
                let tail = first.replacingOccurrences(of: "USERNAME=", with: "")
                
                if tail.count > 2 {
                    let second = values[1]
                    
                    if second.starts(with: "TOKEN=") {
                        
                        let tail = second.replacingOccurrences(of: "TOKEN=", with: "")
                        
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
