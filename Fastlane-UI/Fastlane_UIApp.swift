//
//  Fastlane_UIApp.swift
//  Fastlane-UI
//
//  Created by softwave on 21/07/23.
//

import SwiftUI

@main
struct Fastlane_UIApp: App {
    
    @State private var useSprintForJiraQuery = false
    @State private var useBranchForJiraQuery = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                useSprintForJiraQuery: $useSprintForJiraQuery,
                useBranchForJiraQuery: $useBranchForJiraQuery
            ).task {
                let file = try? await Files.Jira.TicketsManagement.Reader.read()
                useSprintForJiraQuery = file?.useSprintForQuery ?? false
                useBranchForJiraQuery = file?.useBranchForQuery ?? false
            }
        }
    }
}
