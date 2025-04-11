//
//  JiraQuery.swift
//  Fastlane-UI
//
//  Created by softwave on 11/04/25.
//

import SwiftUI

extension Jira {
    struct Query: View {
        
        @Binding var useSprint: Bool
        @Binding var useBranch: Bool
        
        var body: some View {
            HStack {
                Toggle(" Use sprint", isOn: $useSprint)
                Toggle(" Use branch", isOn: $useBranch)
            }
            .padding()
        }
    }
}
