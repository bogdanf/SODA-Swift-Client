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
        let count, offset, limit, totalResults: Int
    }

    struct Item<T: Codable>: Codable, Identifiable {
        let id, etag, lastModified, created: String
        let value: T
    }
    
    static let agent = Agent()
    static let endpoint = URL(string: "https://RAYM56Z0MUISRHO-DBJSON1.adb.eu-frankfurt-1.oraclecloudapps.com/ords/admin/soda/latest")!
    static let authorization = "ADMIN:Bf24011972!@"
}

extension SODA {
    
    static func documents<T>(collection: String) -> AnyPublisher<SODA.Collection<T>, Error> {
        let loginData = SODA.authorization.data(using: String.Encoding.utf8)!.base64EncodedString()
        
        var request = URLRequest(url: endpoint.appendingPathComponent("\(collection)"))
        request.setValue("Basic \(loginData)", forHTTPHeaderField: "Authorization")
        
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
