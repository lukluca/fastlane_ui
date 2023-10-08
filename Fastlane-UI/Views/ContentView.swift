//
//  ContentView.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import SwiftUI

enum Segment : String, CaseIterable {
    case deployApp = "Deploy App"
    case firebase = "Firebase"
    case jiraTools = "Jira tools"
    case tools = "Tools"
}

struct ContentView: View {
    
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

struct SegmentView: View {
    
    @Binding var selectedSement: Segment

    var body: some View {
        switch selectedSement {
        case .deployApp:
            DeployApp()
        case .firebase:
            Firebase()
        case .jiraTools:
            JiraTools()
        case .tools:
            Tools()
        }
    }
}
