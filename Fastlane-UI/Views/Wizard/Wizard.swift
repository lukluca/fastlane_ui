//
//  Wizard.swift
//  Fastlane-UI
//
//  Created by softwave on 15/11/23.
//

import SwiftUI
import Combine

struct Wizard: View {
    
    @ObservedObject private var currentStep : Step = .initial
    
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
                        StepCircleView(text: "\($0.index + 1)",
                                       isLast: $0.isLast,
                                       isDone: ($0.isLast && stepCompleted.isCompleted) ? true : $0.index < stepCompleted.count )
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
                    if let kind = Step.Kind(index: currentStep.rawValue - 1) {
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
                            if let kind = Step.Kind(index: currentStep.rawValue + 1) {
                                currentStep.kind = kind
                            } else {
                                isNextButtonDisabled = true
                            }
                        }
                        
                        switch currentStep.kind {
                        case .projectFolder:
                            do {
                                if try ProjectFolder.containsGitRepo() {
                                    errorText = ""
                                    goToNextStep()
                                } else {
                                    errorText = "The folder does not contain a git repo!"
                                    isNextButtonDisabled = true
                                }
                            } catch {
                                errorText = error.localizedDescription
                                isNextButtonDisabled = true
                            }
                        case .jira:
                            goToNextStep()
                        case .completed:
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
                isNextButtonDisabled = !currentStep.isDone
                isBackButtonDisabled = currentStep.rawValue == 0
                isCompleted = stepCompleted.isCompleted
            }.onChange(of: currentStep.kind) { newValue in
                isBackButtonDisabled = newValue.index == 0
                isNextButtonDisabled = newValue.index == (Step.Kind.allCases.count - 1)
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
            case .jira:
                JiraItem()
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
    
    struct JiraItem: View {
        
        @State private var isChecked = false
        
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
                
                Text("Inside the folder must be a file named 'credentials' of this structure\n\nUSERNAME=\"JIRA_USERNAME\" \nTOKEN=\"JIRA_TOKEN\"\n\nPlease replace JIRA_USERNAME and JIRA_TOKEN with your credentials")
                    .opacity(isChecked ? 1 : 0.5)
                
                Text("You can configure the status of the ticket to show inside release note from the Jira tools tab.")
                    .opacity(isChecked ? 1 : 0.5)
                
            }.onAppear {
                isChecked = useJira
            }.onChange(of: isChecked) { newValue in
                useJira = isChecked
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
        
        private var bag = [AnyCancellable]()
    
        @Published var kind: Kind {
            didSet {
                bag.removeAll()
                bindIsDone()
            }
        }
        
        init(kind: Kind) {
            self.kind = kind
            
            bindIsDone()
        }
        
        private func bindIsDone() {
            switch kind {
            case .projectFolder(let state):
                state.$isDone
                    .assign(to: \.isDone, on: self)
                    .store(in: &bag)
            case .jira(let state):
                state.$isDone
                    .assign(to: \.isDone, on: self)
                    .store(in: &bag)
                break
                
            case .completed:
                break
            }
        }
    }
}

extension Wizard.Step {
    enum Kind {
        case projectFolder(ProjectFolderStepState)
        case jira(JiraFolderStepState)
        case completed
        
        var index: Int {
            switch self {
            case .projectFolder:
                return 0
            case .jira:
                return 1
            case .completed:
                return 2
            }
        }
        
        var isLast: Bool {
            self == .completed
        }
        
        init?(index: Int) {
            switch index {
            case 0:
                self = .projectFolder(ProjectFolderStepState())
            case 1:
                self = .jira(JiraFolderStepState())
            case 2:
                self = .completed
            default:
                return nil
            }
        }
    }
}

extension Wizard.Step.Kind: Equatable {
    static func == (lhs: Wizard.Step.Kind, rhs: Wizard.Step.Kind) -> Bool {
        lhs.index == rhs.index
    }
}

extension Wizard.Step.Kind: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
}

extension Wizard.Step.Kind: Identifiable {
    var id: Int {
        index
    }
}

extension Wizard.Step.Kind: CaseIterable {
    static let allCases: [Wizard.Step.Kind] = [.projectFolder(ProjectFolderStepState()), .jira(JiraFolderStepState()), .completed]
}

extension Wizard.Step: ObservableObject {}

extension Wizard.Step {
    static let initial = Wizard.Step(kind: .projectFolder(ProjectFolderStepState()))
}

extension Wizard.Step: RawRepresentable {
    
    var rawValue: Int {
        kind.index
    }
    
    convenience init?(rawValue: Int) {
        guard let kind = Kind(index: rawValue) else {
            return nil
        }
        self.init(kind: kind)
    }
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
        
        isDone = ProjectFolder.validate()
        
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

final class JiraFolderStepState: ObservableObject {
    
    @Published var isDone = false
    
    private var bag = [AnyCancellable]()
    
    init() {
        
        isDone = JiraFolderStepState.validate()
        
        Defaults.shared.objectWillChange.map {
            JiraFolderStepState.validate()
        }
        .removeDuplicates()
        .assign(to: \.isDone, on: self)
        .store(in: &bag)
    }
    
    fileprivate static func validate() -> Bool {
        guard Defaults.shared.useJira else {
            return true
        }
        return Defaults.shared.jiraCredentialsFolder != ""
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
            .map { $0 == 2 }
            .assign(to: \.isCompleted, on: self)
            .store(in: &bag)
        
        count = [ProjectFolder.validate(),
                 JiraFolderStepState.validate()].filter { $0 }.count
    }
}

private enum ProjectFolder {
    static func validate() -> Bool {
        isValid(Defaults.shared.projectFolder)
    }
    
    static func isValid(_ string: String) -> Bool {
        string != ""
    }
    
    static func containsGitRepo() throws -> Bool {
        let fm = FileManager.default
        let path = Defaults.shared.projectFolder
        return try fm.contentsOfDirectory(atPath: path).contains { $0 == ".git" }
    }
}
