//
//  Slack.swift
//  Fastlane-UI
//
//  Created by softwave on 24/11/23.
//

import SwiftUI

struct Slack: View {
    
    @Default(\.notifySlack) private var notifySlack
   
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Toggle(" Notify Slack", isOn: $notifySlack)
            }
        }
        .padding()
    }
}
