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
    
    private var bag = [AnyCancellable]()
    
    var body: some View {
        VStack(spacing: 10) {
            
            Text("Wizard")
            
            ScrollView{
                HStack(spacing: 0){
                    ForEach(Step.Kind.allCases) {
                        StepCircleView(text: "\($0.index + 1)",
                                       isLast: $0.index == (Step.Kind.allCases.count - 1),
                                       isDone: $0.index != 9)
                    }
                }
            }
            .frame(height: 40)
            .padding()
            
            StepContent(current: $currentStep.kind)
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
                
                Button {
                    isBackButtonDisabled = false
                    if let kind = Step.Kind(index: currentStep.rawValue + 1) {
                        currentStep.kind = kind
                    } else {
                        isNextButtonDisabled = true
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
            .onAppear {
                isNextButtonDisabled = !currentStep.isDone
                isBackButtonDisabled = currentStep.rawValue == 0
            }.onChange(of: currentStep) { newValue in
                isBackButtonDisabled = newValue.rawValue == 0
                isNextButtonDisabled = newValue.rawValue == (Step.Kind.allCases.count - 1)
            }
            .onChange(of: currentStep.isDone) { newValue in
                isNextButtonDisabled = !newValue
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

        var body: some View {
            switch current {
            case .projectFolder:
                ProjectFolderItem()
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
        
        var body: some View {
            VStack(spacing: 20) {
                ProjectFolderView(projectFolder: $projectFolder)
                    .padding(.horizontal, 20)
                
                Text("This is the folder on your mac where the git froject is stored. Must not be empty.")
            }
        }
    }
    
    struct JiraItem: View {
        
        @State private var isChecked = false
        
        @Default(\.jiraCredentialsFolder) private var jiraCredentialsFolder: String
        
        var body: some View {
            VStack(spacing: 20) {
                Toggle(isOn: $isChecked) {
                    Text("Enable Jira")
                }
                .toggleStyle(.checkbox)
                
                if isChecked {
                    JiraCredentialsFoldetView(credentialsFolder: $jiraCredentialsFolder)
                        .padding(.horizontal, 20)
                }
                
                Text("If you wish to make release notes from Jira, please fill the folder where the credential is stored. Must not be empty.")
                
                Text("You can configure the status of the ticket to show inside release note from the Jira tools tab.")
            }.onAppear {
                isChecked = jiraCredentialsFolder != ""
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

class ProjectFolderStepState: ObservableObject {
    
    @Published var isDone = false
    
    private var bag = [AnyCancellable]()
    
    init() {
        
        isDone = ProjectFolderStepState.validate()
        
        Defaults.shared.objectWillChange.map {
            ProjectFolderStepState.validate()
        }
        .removeDuplicates()
        .assign(to: \.isDone, on: self)
        .store(in: &bag)
    }
    
    private static func validate() -> Bool {
        Defaults.shared.projectFolder != ""
    }
}

class JiraFolderStepState: ObservableObject {
    
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
    
    private static func validate() -> Bool {
        Defaults.shared.jiraCredentialsFolder != ""
    }
}
