//
//  Network+Jira.swift
//  Fastlane-UI
//
//  Created by softwave on 20/03/24.
//

import Foundation

extension Network {
    struct Jira {
        
        func fetchSprints() async -> Result<Set<Sprint>, Error> {
            
            do {
                guard let name = try await fetchSprintFieldName() else {
                    return .success([])
                }
                
                let response = try await search(customField: name)
                
                let sprints = response.issues.compactMap { issue in
                    let activeSprints = issue.fields.custom?.filter { field in
                        field.state == "active"
                    }
                    return activeSprints?.map {
                        Sprint(id: $0.id, name: $0.name)
                    }
                }.flatMap{ $0 }
                
                return .success(Set(sprints))

            } catch {
                return .failure(error)
            }
        }
        
        private func fetchSprintFieldName() async throws -> String?  {
            
            let host = try Files.Jira.Host.read()
            
            guard let url = URL(string: "\(host.url)/rest/api/3/field") else {
                throw NetworkError.invalidURL
            }
            
            let response = try await URLSession.shared.object(
                [Jira.FieldResponse].self,
                for: try Jira.Request(url: url).asURLRequest()
            )
            
            return response.first {
                $0.name == "Sprint"
            }?.key
        }
        
        private func search(customField: String) async throws -> Jira.SearchResponse {
            
            let host = try Files.Jira.Host.read()
            
            guard var components = URLComponents(string: "\(host.url)/rest/api/2/search") else {
                throw NetworkError.invalidComponents
            }
            
            let value = "project = \(host.project)"
            
            components.queryItems = [URLQueryItem(name: "jql", value: value)]
            
            guard let url = components.url else {
                throw NetworkError.invalidURL
            }
            
            FieldsConfigurationProviding.decodingConfiguration = customField
            
            return try await URLSession.shared.object(
                Jira.SearchResponse.self,
                for: try Jira.Request(url: url).asURLRequest()
            )
        }
    }
}

//MARK: Models

extension Network.Jira {
    struct Request {
        let url: URL
        
        func asURLRequest() throws -> URLRequest {
            var request = URLRequest(url: url)
            
            let credentials = try Files.Jira.Credentials.read()
            
            let basicAuth = "\(credentials.username):\(credentials.token)"
            let basicEncoded = basicAuth.data(using: .utf8)?.base64EncodedString() ?? ""

            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Basic \(basicEncoded)", forHTTPHeaderField: "Authorization")
            return request
        }
    }

    struct FieldResponse: Decodable {
        let key: String
        let name: String
    }

    struct SearchResponse: Decodable {
        let issues: [Issue]
    }
    
    struct Sprint {
        let id: Int
        let name: String
        
        static let none = Sprint(id: -1, name: "None")
    }
}

extension Network.Jira.Sprint: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Network.Jira.SearchResponse {
    struct Issue: Decodable {
        @DecodableConfiguration(from: FieldsConfigurationProviding.self) var fields = Fields()
    }
}

struct FieldsConfigurationProviding: DecodingConfigurationProviding {
    static var decodingConfiguration = ""
}

extension Network.Jira.SearchResponse.Issue {
    struct Fields: Decodable, DecodableWithConfiguration {
        
        let custom: [Field]?
        
        private struct CustomCodingKeys: CodingKey {
            var stringValue: String
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            var intValue: Int?
            init?(intValue: Int) {
                return nil
            }
        }
        
        init() {
            custom = []
        }
        
        init(from decoder: any Decoder, configuration: String) throws {
            let container = try decoder.container(keyedBy: CustomCodingKeys.self)
            
            if let key = CustomCodingKeys(stringValue: configuration) {
                let value = try? container.decode([Field].self, forKey: key)
                self.custom = value
            } else {
                self.custom = nil
            }
        }
    }
}

extension Network.Jira.SearchResponse.Issue.Fields {
    struct Field: Decodable {
        let id: Int
        let name: String
        let state: String
    }
}

@propertyWrapper struct DecodableConfiguration<T, ConfigurationProvider> : Decodable where T : DecodableWithConfiguration, ConfigurationProvider : DecodingConfigurationProviding, T.DecodingConfiguration == ConfigurationProvider.DecodingConfiguration {

    var wrappedValue: T

    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    init(wrappedValue: T, from configurationProvider: ConfigurationProvider.Type) {
        self.wrappedValue = wrappedValue
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    init(from decoder: any Decoder) throws {
        self.wrappedValue = try T(from: decoder, configuration: ConfigurationProvider.decodingConfiguration)
    }
}
