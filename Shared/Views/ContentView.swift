//
//  ContentView.swift
//  Shared
//
//  Created by Bogdan Farca on 26/08/2020.
//

import SwiftUI

struct ContentView: View {
   
    @StateObject var dataStore = DataStore()
       
    var body: some View {
        Text("Fruits")
            .font(.largeTitle)
        
        List(dataStore.fruits) { fruit in
            Text("\(fruit.value.count)")
                + Text(" \(fruit.value.color ?? "colorless")")
                + Text(" \(fruit.value.name)s").font(Font.body.bold())
        }
    }
}
