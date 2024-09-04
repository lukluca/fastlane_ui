//
//  ListView.swift
//  Fastlane-UI
//
//  Created by softwave on 08/10/23.
//

import SwiftUI

@MainActor
protocol TextFieldRowsGetter {
    var readRows: [TextFieldRow.Model] { get }
    var currentRows: [TextFieldRow.Model] { get }
}

struct ListView: View {
    
    let title: String
    let gitMessage: String
    let isEnableButtonHidden: Bool
    let rowsGetter: TextFieldRowsGetter
    let shell = Defaults.shared.shell
    let isCommitActionDisabled: ([TextFieldRow.Model]) -> Bool
    let commit: () -> ()
    
    @State private var isMainActionDisabled = true
    
    @Binding var rows: [TextFieldRow.Model]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text(title)
                Button {
                    rows.append(TextFieldRow.Model())
                } label: {
                    Image(systemName: "plus.circle")
                }
                Button {
                    rows = rowsGetter.readRows
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            ForEach($rows, id: \.uid) { row in
                TextFieldRow(isEnableButtonHidden: isEnableButtonHidden, model: row) {
                    rows.removeAll { another in
                        another.uid == row.wrappedValue.uid
                    }
                } commitAction: {
                    isMainActionDisabled = isCommitActionDisabled(rows)
                }
            }
            
            Button("Commit and push") {
                executeCommitAndPush()
            }
            .disabled(isMainActionDisabled)
        }
        .onAppear {
            rows = rowsGetter.currentRows
        }.onChange(of: rows) { _, newValue in
            isMainActionDisabled = isCommitActionDisabled(newValue)
        }
    }
}

private extension ListView {
    func executeCommitAndPush() {
        commit()
        let branch = Defaults.shared.branchName
        let cd = shell.cd(folder: Defaults.shared.projectFolder)
        let checkout = shell.gitCheckout(branch: branch)
        let add = shell.gitAdd(file: jiraReleaseNotesStatusPathComponent)
        let commit = shell.gitCommit(message: gitMessage)
        let push = shell.gitPush(branch: branch)
        
        let _ = runBundleScript(with: [cd, checkout, add, commit, push])
    }
}

extension ListView: ShellWorkflow {}
