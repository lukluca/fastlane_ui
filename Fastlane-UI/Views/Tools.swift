//
//  Tools.swift
//  Fastlane-UI
//
//  Created by softwave on 06/09/23.
//

import SwiftUI
import RadioButton

struct Tools: View {
    
    @Default(\.shell) private(set) var shell: Shell
    
    @Default(\.needsSudo) private var needsSudo: Bool
    
    @State private var result = ""
    
    var body: some View {
        VStack {
            List {
                Section("Settings") {
                    RadioButton(title: "Shell:",
                                itemTitle: \.rawValue,
                                isSelected: $shell)
                }
                Section("Fastlane") {
                    
                    VStack(alignment: .center, spacing: 10) {
                        
                        Toggle(" Needs sudo", isOn: $needsSudo)
                        
                        Button("Update") {
                            result = update()
                        }
                        
                        Button("Update plugins") {
                            result = updatePlugins()
                        }
                        
                        Button("Update all") {
                            result = updateAll()
                        }
                    }
                }
            }
            
            Text(result)
        }
    }
}

extension Tools: FastlaneWorkflow {}

private extension Tools {
    
    private var updateCommand: String {
        FastlaneCommand.update.fullCommand(needsSudo: needsSudo)
    }
    
    private var updatePluginsCommand: String {
        FastlaneCommand.updatePlugins.fullCommand(needsSudo: needsSudo)
    }
    
    func update() -> String {
        runBundleScript(with: [updateCommand])
    }
    
    func updateAll() -> String {
        runBundleScript(with: [updateCommand, updatePluginsCommand])
    }
    
    func updatePlugins() -> String {
        runBundleScript(with: [updatePluginsCommand])
    }
}
