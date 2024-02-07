//
//  View+.swift
//  Fastlane-UI
//
//  Created by softwave on 07/09/23.
//

import SwiftUI

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
