//
//  JiraConfig.swift
//  Fastlane-UI
//
//  Created by softwave on 18/09/23.
//

import SwiftUI

struct JiraConfig: View {
    
    @Binding var projectFolder: String
    
    let shell = Defaults.shared.shell
    
    private let statusManager = TicketStatus()
    
    @State private var rows = [JiraConfig.Row.Model]()
    
    @State private var isMainActionDisabled = true
    
    private var status: [String] {
        rows.status
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ProjectFolderView(projectFolder: $projectFolder)
            
            HStack {
                Text("Ticket status")
                Button {
                    rows.append(JiraConfig.Row.Model())
                } label: {
                    Image(systemName: "plus.circle")
                }
                Button {
                    rows = (try? statusManager.read())?.rows ?? []
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            ForEach($rows, id: \.uid) { row in
                Row(model: row) {
                    rows.removeAll { another in
                        another.uid == row.wrappedValue.uid
                    }
                } commitAction: {
                    isMainActionDisabled = status == statusManager.current
                }
            }
            
            Button("Commit and push") {
                executeCommitAndPush()
            }
            .disabled(isMainActionDisabled)
        }
        .onAppear {
            rows = statusManager.current.rows
        }.onChange(of: rows) { newValue in
            isMainActionDisabled = newValue.status == statusManager.current
        }
    }
    
    private func commit() {
        do {
            try statusManager.apply(status: status)
        } catch {
            print(error)
        }
    }
}

extension JiraConfig: ShellWorkflow {}

private extension JiraConfig {
    func executeCommitAndPush() {
        commit()
        let branch = Defaults.shared.branchName
        let cd = shell.cd(folder: projectFolder)
        let checkout = shell.gitCheckout(branch: branch)
        let add = shell.gitAdd(file: jiraWorkflowStatusPathComponent)
        let commit = shell.gitCommit(message: "Update name of jira ticket status")
        let push = shell.gitPush(branch: branch)
        
        let _ = runBundleScript(with: [cd, checkout, add, commit, push])
    }
}

private extension JiraConfig {
    struct Row: View {
        
        @FocusState private var isTextFieldFocused: Bool
        
        @State private var text: String = ""
        
        @Binding var model: Model
        
        let ereaseAction: () -> ()
        let commitAction: () -> ()
        
        var body: some View {
            HStack {
                TextField("",
                          text: $text)
                .textFieldStyle(.squareBorder)
                .focused($isTextFieldFocused)
                .onChange(of: isTextFieldFocused) { isFocused in
                }
                
                Button(action: ereaseAction,
                       label: {
                    Image(systemName: "minus.circle")
                })
            }
            .onAppear {
                text = model.text
            }
            .onChange(of: text) { newValue in
                model.text = newValue
                commitAction()
            }
        }
    }
}

private extension JiraConfig.Row {
    class Model {
        
        let uid = UUID().uuidString
        
        var text: String = ""
        
        init(text: String) {
            self.text = text
        }
        
        init() {
            self.text = ""
        }
    }
}

extension JiraConfig.Row.Model: Equatable {
    static func == (lhs: JiraConfig.Row.Model, rhs: JiraConfig.Row.Model) -> Bool {
        lhs.uid == rhs.uid
    }
}

private class TicketStatus {
    
    @Default(\.projectFolder) private var projectFolder: String
    
    private(set) var current = [String]()
    
    private let separator = ", "
    
    private var path: String {
        projectFolder + "/" + jiraWorkflowStatusPathComponent
    }
    
    init() {
        let _ = try? read()
    }
    
    func apply(status: [String]) throws {
        let filtered = status.filter { $0 != ""}
        let stored = try read()
        let uni = filtered.uniqued()
        if stored != uni {
            try store(status: uni)
        }
    }

    func read() throws -> [String] {
        let values = try String(contentsOfFile: path).components(separatedBy: separator)
        current = values
        return values
    }
    
    private func store(status: [String]) throws {
        
        let url = URL(fileURLWithPath: path)
        
        func save(string: String) throws {
            if let stringData = string.data(using: .utf8) {
                try stringData.write(to: url)
            }
        }
        
        try save(string: "")
        current.removeAll()
        let toSave = status.joined(separator: separator)
        try save(string: toSave)
        current = status
    }
}

private extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

private extension Array where Element == JiraConfig.Row.Model {
    var status: [String] {
        map(\.text)
    }
}

private extension Array where Element == String {
    var rows: [JiraConfig.Row.Model] {
        map {
            JiraConfig.Row.Model(text: $0)
        }
    }
}
