//
//  AtpAPI.swift
//  ATP Client
//
//  Created by Bogdan Farca on 26/08/2020.
//

import Foundation
import Combine

enum AutonomousAPI {
    static let agent = Agent()
    static let base = URL(string: "https://RAYM56Z0MUISRHO-DBJSON1.adb.eu-frankfurt-1.oraclecloudapps.com/ords/admin/soda/latest")!
    static let authorization = "ADMIN:Bf24011972!@"
}

extension AutonomousAPI {
    
    static func documents(collection: String) -> AnyPublisher<ATPCollection, Error> {
        let loginData = AutonomousAPI.authorization.data(using: String.Encoding.utf8)!.base64EncodedString()
       
        var request = URLRequest(url: base.appendingPathComponent("\(collection)"))
        request.setValue("Basic \(loginData)", forHTTPHeaderField: "Authorization")
        
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}

// MARK: - Welcome
struct ATPCollection: Codable {
    let items: [Item]
    let hasMore: Bool
    let count, offset, limit, totalResults: Int
}

// MARK: - Item
struct Item: Codable, Identifiable {
    let id, etag, lastModified, created: String
    let value: Fruit
}

// MARK: - Value
struct Fruit: Codable {
    let name: String
    let count: Int
    let color: String?
}
