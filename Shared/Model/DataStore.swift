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
    static let shared: DataStore = DataStore()
    
    init() {
        retrieveAllFruits()
    }
    
    func retrieveAllFruits() {
        SODA.documents(collection: "fruit")
            .map(\.items)
            .assertNoFailure("Error retrieving documents") // Let's ignore the errors for now
            .receive(on: DispatchQueue.main)
            .assign(to: \.fruits, on: self)
            .store(in: &tokens)
    }
    
    func retrieveFruit(with id: String) -> AnyPublisher<Fruit, Error> {
        SODA.document(id: id, in: "fruit")
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    // MARK:- Helper functions
    func modelUpdate(fruit: SODA.Item<Fruit>, with newValue: Fruit) {
        guard let idx = fruits.firstIndex(where: { $0.id == fruit.id }) else { return }
        fruits[idx].value = newValue
    }
}
