//
//  Sequence+.swift
//  Fastlane-UI
//
//  Created by softwave on 08/10/23.
//

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
