//
//  AtpAPI.swift
//  ATP Client
//
//  Created by Bogdan Farca on 26/08/2020.
//

import Foundation
import Combine

enum SODA {
    
    struct Collection<T: Codable>: Codable {
        let items: [Item<T>]
        let hasMore: Bool
        let count, offset, limit: Int
        let totalResults: Int?
    }

    struct Item<T: Codable>: Codable, Identifiable {
        let id, etag, lastModified, created: String
        var value: T
    }
    
    static let agent = Agent()
    static let endpoint = "https://RAYM56Z0MUISRHO-DBJSON1.adb.eu-frankfurt-1.oraclecloudapps.com/ords/admin/soda/latest"
    static let authorization = ProcessInfo.processInfo.environment["API-KEY"]!
}

extension SODA {
    
    /// Retrieve all documents in a collection
    static func documents<T>(collection: String, pageSize: Int = 0) -> AnyPublisher<SODA.Collection<T>, Error> {
        let request = SODARequest("\(collection)", parameters: pageSize == 0 ? [:] : ["limit" : "\(pageSize)"])
        
        // The base publisher needed as a way to recursively retrieve all the pages
        let urlPublisher = CurrentValueSubject<URLRequest, Error>(request)
        
        return urlPublisher
            .flatMap {
                agent.run($0)
                    .handleEvents(receiveOutput: {
                        if $0.value.hasMore {
                            let offset = $0.value.offset + $0.value.count
                            let nextRequest = SODARequest("\(collection)", parameters: ["limit" : "\($0.value.limit)", "offset": "\(offset)"])
                            urlPublisher.send(nextRequest)
                        } else {
                            urlPublisher.send(completion: .finished)
                        }
                    })
            }
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    /// Retrieve one document at a time
    static func document<T: Decodable>(id: String, in collection: String) -> AnyPublisher<T, Error> {
        let request = SODARequest("\(collection)/\(id)")
        
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    /// Update one document with the content of entity
    static func update<T: Encodable>(id: String, collection: String, with entity: T) -> AnyPublisher<Void, Error> {
        var request = SODARequest("\(collection)/\(id)")
        request.httpMethod = "PUT"
        
        if let json = try? JSONEncoder().encode(entity) {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = json
        }

        return agent.run(request)
            .map { () } // converting to Void
            .eraseToAnyPublisher()
    }
    
    // MARK:- Helpers
    
    private static func SODARequest(_ suffix: String, parameters: [String:String] = [:]) -> URLRequest {
        var queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var urlComponents = URLComponents(string: endpoint)!
        urlComponents.queryItems = queryItems
        
        let requestURL = urlComponents.url!.appendingPathComponent(suffix)
        var request = URLRequest(url: requestURL)
        
        let loginData = SODA.authorization.data(using: String.Encoding.utf8)!.base64EncodedString()
        request.setValue("Basic \(loginData)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
