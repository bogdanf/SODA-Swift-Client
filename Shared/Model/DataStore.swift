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
    @Published var isLoading = false
    
    static let shared: DataStore = DataStore()
    private var tokens = Set<AnyCancellable>()
    
    init() {
        retrieveAllFruits()
    }
    
    func retrieveAllFruits() {
        guard !isLoading else { return }
        
        isLoading = true
        fruits = []
        
        SODA.documents(collection: "fruit", pageSize: 100)
            .map(\.items)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.isLoading = false
            } receiveValue: { (records: [SODA.Item<Fruit>]) in
                self.fruits.append(contentsOf: records)
            }
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
