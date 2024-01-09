//
//  String+.swift
//  Fastlane-UI
//
//  Created by softwave on 09/01/24.
//

import Foundation

extension String {
    func purge(using key: String) -> String? {
        guard starts(with: key) else {
            return nil
        }
        let first = String(dropFirst(key.count + 1))
        
        if first.starts(with: "\"") {
            let removed = String(first.dropFirst())
            
            if removed.last == "\"" {
                return String(removed.dropLast(1))
            }
            return removed
        }
        
        return first
    }
    
    static func contentsOfFileSeparatedByNewLine(path: String) throws -> [String] {
        try String(contentsOfFile: path).components(separatedBy: "\n")
    }
}
