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
                Section("Wizard") {
                    Button("Erease data", role: .destructive) {
                        Defaults.shared.reset()
                    }
                    Button("Show wizard") {
                        Defaults.shared.showWizard = true
                    }
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
                        
                        Button("Rubocop") {
                            result = rubocop()
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
    
    private var rubocopCommand: String {
        FastlaneCommand.rubocop.fullCommand(needsSudo: needsSudo, with: RubocopArguments())
    }
    
    private var cdProjectFolderCommand: String {
        shell.cd(folder: Defaults.shared.projectFolder)
    }
    
    func update() -> String {
        runBundleScript(with: [cdProjectFolderCommand, updateCommand])
    }
    
    func updateAll() -> String {
        runBundleScript(with: [cdProjectFolderCommand, updateCommand, updatePluginsCommand])
    }
    
    func updatePlugins() -> String {
        runBundleScript(with: [cdProjectFolderCommand, updatePluginsCommand])
    }
    
    func rubocop() -> String {
        runBundleScript(with: [cdProjectFolderCommand, rubocopCommand])
    }
}
