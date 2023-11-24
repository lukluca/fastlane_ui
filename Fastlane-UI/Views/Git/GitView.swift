//
//  GitView.swift
//  Fastlane-UI
//
//  Created by softwave on 24/11/23.
//

import SwiftUI

struct GitView: View {
    
    @Default(\.pushOnGit) private var pushOnGit: Bool
    @Default(\.mainFolder) private var mainFolder: String
    @Default(\.remoteURL) private var remoteURL: String
    @Default(\.cloneFromRemote) private var cloneFromRemote: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 10) {
                
                if cloneFromRemote {
                    MainFolderView(mainFolder: $mainFolder)
                    
                    HStack {
                        Text("Git remote url")
                        TextField("Enter your git remote url", text: $remoteURL)
                    }
                    
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(" Push on Git tag and commit", isOn: $pushOnGit)
                    Toggle(" Clone git from remote", isOn: $cloneFromRemote)
                }
            }
        }
        .padding()
    }
}
