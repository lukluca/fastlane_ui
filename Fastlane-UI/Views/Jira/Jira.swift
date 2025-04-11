//
//  Jira.swift
//  Fastlane-UI
//
//  Created by softwave on 18/09/23.
//

import SwiftUI

struct Jira: View {
    
    @Binding var useSprintForQuery: Bool
    @Binding var useBranchForQuery: Bool
    
    var body: some View {
        VStack {
            List {
                Section("Tickets status management") {
                    TiketsStatus()
                }
                Section("Release notes") {
                    ReleaseNotes()
                }
                
                Section("Make version") {
                    MakeVersion()
                }
                
                Section("Query") {
                    Query(
                        useSprint: $useSprintForQuery,
                        useBranch: $useBranchForQuery
                    )
                }
            }
        }
    }
}
