//
//  JiraTiketsStatus.swift
//  Fastlane-UI
//
//  Created by softwave on 18/09/23.
//

import SwiftUI

extension Jira {
    struct TiketsStatus: View {
        
        private let statusManager = TicketStatus()
        
        @State private var rows = [TextFieldRow.Model]()
        
        var body: some View {
            ListView(
                title: "Ticket status",
                gitMessage: "Update name of jira ticket status",
                isEnableButtonHidden: true,
                rowsGetter: self,
                isCommitActionDisabled: { models in
                    models.texts == statusManager.current
                },
                commit: commit,
                rows: $rows)
        }
        
        private func commit() {
            do {
                try statusManager.apply(status: rows.texts)
            } catch {
                print(error)
            }
        }
    }
}

extension Jira.TiketsStatus: TextFieldRowsGetter {
    var readRows: [TextFieldRow.Model]  {
        (try? statusManager.read())?.rows ?? []
    }
    var currentRows: [TextFieldRow.Model] {
        statusManager.current.rows
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

private extension Array where Element == TextFieldRow.Model {
    var texts: [String] {
        map(\.text)
    }
}

private extension Array where Element == String {
    var rows: [TextFieldRow.Model] {
        map {
            TextFieldRow.Model(text: $0)
        }
    }
}
