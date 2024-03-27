//
//  Files.swift
//  Fastlane-UI
//
//  Created by softwave on 23/03/24.
//

import Foundation

enum Files {
}

extension Files {
    static func decode<T>(_ type: T.Type, from file: String) throws -> T where T : Decodable {
        let dict = try Dictionary(from: file)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromUpperAndSnakeCase
        
        return try decoder.decode(
            T.self,
            from: JSONSerialization.data(withJSONObject: dict))
    }
    
    static func save<T>(_ value: T, to file: String) throws where T : Encodable {

        let encoder = JSONEncoder()
        
        encoder.keyEncodingStrategy = .convertToUpperAndSnakeCase
        
        let dict = (try JSONSerialization.jsonObject(with: encoder.encode(value)) as? [String: String]) ?? [:]
        
        let properties = dict.map { $0.0 + "=" + $0.1 }.joined(separator: "\n")
        try properties.write(toFile: file, atomically: true, encoding: .utf8)
    }
}

private extension JSONDecoder.KeyDecodingStrategy {

    static let convertFromUpperAndSnakeCase = JSONDecoder.KeyDecodingStrategy.custom { keys in
        LowercaseCamelKey(stringValue: keys.last?.stringValue ?? "")
    }
 }

private extension JSONEncoder.KeyEncodingStrategy {

    static let convertToUpperAndSnakeCase = JSONEncoder.KeyEncodingStrategy.custom { keys in
        UppercaseSnakeKey(stringValue: keys.last?.stringValue ?? "")
    }
 }

private struct LowercaseCamelKey: CodingKey {
    
    var stringValue: String
    init(stringValue: String) {
        let lower = stringValue.lowercased()
        
        let components = lower.split(separator: "_")
        
        switch components.count {
        case 0, 1:
            self.stringValue = lower
        default:
            self.stringValue = components.reduce("") { partialResult, nextValue in
              partialResult.isEmpty ? String(nextValue) : (partialResult + nextValue.capitalized)
            }
            
        }
    }
    
    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
}

private struct UppercaseSnakeKey: CodingKey {
    
    var stringValue: String
    init(stringValue: String) {
        self.stringValue = stringValue.camelCaseToSnakeCase.uppercased()
    }
    
    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
}

private extension String {
    var camelCaseToSnakeCase: String {
        return unicodeScalars.dropFirst().reduce(String(prefix(1))) {
            return CharacterSet.uppercaseLetters.contains($1)
                ? $0 + "_" + String($1)
                : $0 + String($1)
        }
    }
}

private extension Dictionary where Key == String, Value == String {
    
    init(from propertyFile: String) throws {
        let properties = try String.contentsOfFileSeparatedByNewLine(path: propertyFile)
        
        let keysAndValues: [(String, String)] = properties.compactMap {
            let components = $0.components(separatedBy: "=")
            
            guard components.count >= 2 else {
                return nil
            }
            
            let final = components.dropFirst()
            
            return (components[0], final.joined(separator: "="))
        }
        
        self = Dictionary(keysAndValues,
                          uniquingKeysWith: { (lhs, rhs) in lhs })
    }
}
