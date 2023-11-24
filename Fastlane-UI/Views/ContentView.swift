//
//  ContentView.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import SwiftUI

enum Segment: String, CaseIterable {
    case deployApp = "Deploy App"
    case git = "Git"
    case firebase = "Firebase"
    case jira = "Jira"
    case slack = "Slack"
    case tools = "Tools"
    
    static var allCases: [Segment] {
        var cases: [Segment] = [.deployApp]
        
        let defaults = Defaults.shared
        if defaults.useGit {
            cases.append(.git)
        }
        if defaults.useFirebase {
            cases.append(.firebase)
        }
        if defaults.useJira {
            cases.append(.jira)
        }
        if defaults.useSlack {
            cases.append(.slack)
        }
        
        cases.append(.tools)
        
        return cases
    }
}

struct ContentView: View {
    
    @Default(\.showWizard) private var showWizard: Bool
    
    var body: some View {
        if showWizard {
            Wizard()
        } else {
            SegementContent()
        }
    }
}

extension ContentView {

    struct SegementContent: View {
        
        @State private var selectedSegment : Segment = .deployApp
        
        var body: some View {
            Picker("", selection: $selectedSegment) {
                ForEach(Segment.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
           
            Spacer()
            SegmentView(selectedSement: $selectedSegment)
            Spacer()
        }
    }
}

struct SegmentView: View {
    
    @Binding var selectedSement: Segment

    var body: some View {
        switch selectedSement {
        case .deployApp:
            DeployApp()
        case .git:
            GitView()
        case .firebase:
            Firebase()
        case .jira:
            Jira()
        case .slack:
            Slack()
        case .tools:
            Tools()
        }
    }
}
