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
        let count: Int
        let offset, limit, totalResults: Int?
    }

    struct Item<T: Codable>: Codable, Identifiable {
        let id, etag, lastModified, created: String
        var value: T! // should be optional to deal with API responses not including the payload
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
                            let offset = $0.value.offset! + $0.value.count
                            let nextRequest = SODARequest("\(collection)", parameters: ["limit" : "\($0.value.limit!)", "offset": "\(offset)"])
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
    
    /// Add one document with the content of entity
    static func add<T: Codable>(collection: String, with entity: T) -> AnyPublisher<SODA.Item<T>, Error> {
        var request = SODARequest("\(collection)")
        request.httpMethod = "POST"
        
        if let json = try? JSONEncoder().encode(entity) {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = json
        }

        return agent.run(request)
            .map (\.value)
            .tryMap { (added: SODA.Collection<T>) -> SODA.Item<T> in
                // the incoming items collections (actually only one item, the one we added) contains only the meta variables and not the actual payload of the document
                // hopefully, the payload is the entity param, so we add it back
                var newItem = added.items.first!
                newItem.value = entity
                
                return newItem
            }
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
