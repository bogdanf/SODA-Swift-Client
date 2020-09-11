//
//  ContentView.swift
//  Shared
//
//  Created by Bogdan Farca on 26/08/2020.
//

import SwiftUI

struct ContentView: View {
   
    @StateObject var dataStore = DataStore.shared
       
    var body: some View {
        NavigationView {
            List(dataStore.fruits) { fruit in
                NavigationLink(destination: FruitView(fruit: fruit) ) {
                    fruitRow(fruit)
                }
            }
            .environmentObject(dataStore)
            .navigationBarTitle("Fruits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: dataStore.retrieveAllFruits ) {
                        Label("Refresh", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
    
    private func fruitRow(_ fruit: SODA.Item<Fruit>) -> some View {
        Text("\(fruit.value.count)") +
            Text(" \(fruit.value.color ?? "colorless")") +
            Text(" \(fruit.value.name)s").font(Font.body.bold())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
