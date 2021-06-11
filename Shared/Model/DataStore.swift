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
    
    private var tokens = Set<AnyCancellable>()
    
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
    
    //MARK:- View functions
    
    func refresh(fruit: SODA.Item<Fruit>) async -> Fruit {
        await withUnsafeContinuation { c in
            isLoading = true
            
            self.retrieveFruit(with: fruit.id)
                .assertNoFailure()
                .sink { res in
                    self.modelUpdate(fruit: fruit, with: res)
                    self.isLoading = false
                    
                    c.resume(returning: res)
                }
                .store(in: &tokens)
        }
    }
    
    func update(fruit: SODA.Item<Fruit>) async -> SODA.Item<Fruit> {
        await withUnsafeContinuation { c in
            isLoading = true
            
            SODA.update(id: fruit.id, collection: "fruit", with: fruit.value)
                .assertNoFailure()
                .receive(on: DispatchQueue.main)
                .sink {
                    self.modelUpdate(fruit: fruit, with: fruit.value)
                    self.isLoading = false
                    
                    c.resume(returning: fruit)
                }
                .store(in: &tokens)
        }
    }
    
    func add(fruit: SODA.Item<Fruit>) async -> SODA.Item<Fruit> {
        await withUnsafeContinuation { c in
            isLoading = true
            
            SODA.add(collection: "fruit", with: fruit.value!) // Should force unwrap because SODA.Item.value is really an optional, and we want to pass the right type upstream
                .assertNoFailure()
                .receive(on: DispatchQueue.main)
                .sink { item in
                    self.isLoading = false
                    self.modelAdd(fruit: item)
                    
                    c.resume(returning: item)
                }
                .store(in: &tokens)
        }
    }
    
    func addOrUpdate(fruit: SODA.Item<Fruit>) async -> SODA.Item<Fruit> {
        if fruit.id == "" {
            return await add(fruit: fruit)
        } else {
            return await update(fruit: fruit)
        }
    }
    
    
    // MARK:- Helper functions
    func modelUpdate(fruit: SODA.Item<Fruit>, with newValue: Fruit) {
        guard let idx = fruits.firstIndex(where: { $0.id == fruit.id }) else { return }
        fruits[idx].value = newValue
    }
    
    func modelAdd(fruit: SODA.Item<Fruit>) {
        fruits.append(fruit)
    }
    
    func fruit(with id: String) -> SODA.Item<Fruit>? {
        fruits.first { $0.id == id }
    }
}
