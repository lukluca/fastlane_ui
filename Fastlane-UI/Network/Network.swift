//
//  Network.swift
//  Fastlane-UI
//
//  Created by softwave on 20/03/24.
//

import Foundation

enum Network {
    enum NetworkError: Error {
        case invalidURL
        case invalidComponents
    }
}

extension URLSession {
    func object<T>(
        _ type: T.Type,
        for request: URLRequest
    ) async throws -> T where T : Decodable {
        let (data, _) = try await data(for: request)
        return try JSONDecoder().decode(type, from: data)
    }
}
