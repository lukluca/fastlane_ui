//
//  Button+.swift
//  Fastlane-UI
//
//  Created by softwave on 07/02/24.
//

import SwiftUI

extension Button {
    
    init(systemImage: String, action: @escaping () -> Void) where Label == Image {
        self.init(action: action) {
            Image(systemName: systemImage)
        }
    }
}
