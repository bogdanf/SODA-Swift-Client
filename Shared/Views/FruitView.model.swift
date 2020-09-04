//
//  FruitView.model.swift
//  SODA Client
//
//  Created by Bogdan Farca on 01/09/2020.
//

import Foundation
import Combine

extension FruitView {
    class ViewModel: ObservableObject {
        @Published var fruit: SODA.Item<Fruit>
        @Published var isLoading = false
        
        private var tokens = Set<AnyCancellable>()
        
        init(fruit: SODA.Item<Fruit>) {
            self.fruit = fruit
        }
        
        func refreshFruit() {
            isLoading = true
            
            DataStore.shared.retrieveFruit(with: fruit.id)
                .assertNoFailure()
                .sink {
                    DataStore.shared.update(fruit: self.fruit, with: $0)
                    self.isLoading = false
                }
                .store(in: &tokens)
        }
    }
}
