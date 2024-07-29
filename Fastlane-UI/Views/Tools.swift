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
                        
                        Button("Update bundle") {
                            result = updateBundle()
                        }
                        
                        Button("Update fastlane") {
                            result = updateFastlane()
                        }
                        
                        Button("Update fastlane tools") {
                            result = updateFastlaneTools()
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
    
    var updateBundleCommand: String {
        FastlaneCommand.updateBundle.fullCommand(needsSudo: needsSudo)
    }
    
    var updateFastlaneCommand: String {
        FastlaneCommand.updateFastlane.fullCommand(needsSudo: needsSudo)
    }
    
    var updateFastlaneToolsCommand: String {
        FastlaneCommand.updateFastlaneTools.fullCommand(needsSudo: needsSudo)
    }
    
    var updatePluginsCommand: String {
        FastlaneCommand.updatePlugins.fullCommand(needsSudo: needsSudo)
    }
    
    var rubocopCommand: String {
        FastlaneCommand.rubocop.fullCommand(needsSudo: needsSudo, with: RubocopArguments())
    }
    
    var cdProjectFolderCommand: String {
        shell.cd(folder: Defaults.shared.projectFolder)
    }
    
    func updateBundle() -> String {
        runBundleScript(with: [cdProjectFolderCommand, updateBundleCommand])
    }
    
    func updateFastlane() -> String {
        runBundleScript(with: [cdProjectFolderCommand, updateFastlaneCommand])
    }
    
    func updateFastlaneTools() -> String {
        runBundleScript(with: [cdProjectFolderCommand, updateFastlaneToolsCommand])
    }
    
    func updatePlugins() -> String {
        runBundleScript(with: [cdProjectFolderCommand, updatePluginsCommand])
    }
    
    func updateAll() -> String {
        runBundleScript(with: [cdProjectFolderCommand, updateBundleCommand, updateFastlaneCommand, updateFastlaneToolsCommand, updatePluginsCommand])
    }
    
    func rubocop() -> String {
        runBundleScript(with: [cdProjectFolderCommand, rubocopCommand])
    }
}
