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
    
    @MainActor
    var asEnvironment: String {
        let jsonPath = projectFastlanePathComponent + "/" + ".env_mapping.json"
       
        guard let data = try? Data(contentsOf: URL(filePath: jsonPath)) else {
            return self
        }
        
        let mapping = try? JSONDecoder().decode([EnvMapping].self, from: data)

        let mapped = mapping?.first {
            $0.scheme == self
        }
        
        return mapped?.envName ?? self
    }
    
    @MainActor
    var replace: String {
        let defaults = Defaults.shared
        let version = replacingOccurrences(of: "{VERSION_NUMBER}", with: defaults.versionNumber)
        let build = version.replacingOccurrences(of: "{BUILD_NUMBER}", with: "\(defaults.buildNumber)")
        return build.replacingOccurrences(of: "{ENV}", with: defaults.firstScheme.asEnvironment)
    }
}

private struct EnvMapping: Decodable {
    let scheme: String
    let envName: String
    
    enum CodingKeys: String, CodingKey {
        case scheme
        case envName = "env_name"
    }
}
