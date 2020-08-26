//
//  File.swift
//  ATP Client
//
//  Created by Bogdan Farca on 26/08/2020.
//

import Foundation
import Combine

class DataStore: ObservableObject {
    
    @Published var fruits = [SODA.Item<Fruit>]()
    private var tokens = Set<AnyCancellable>()
    
    init() {
        retrieveAllFruits()
    }
    
    func retrieveAllFruits() {
        SODA.documents(collection: "fruit")
            .map(\.items)
            .assertNoFailure() // Let's ignore the errors for now
            .receive(on: DispatchQueue.main)
            .assign(to: \.fruits, on: self)
            .store(in: &tokens)
    }
}
