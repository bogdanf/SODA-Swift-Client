//
//  FruitView.swift
//  SODA Client
//
//  Created by Bogdan Farca on 31/08/2020.
//

import SwiftUI

struct FruitView: View {
    
    @ObservedObject var model: ViewModel
    
    init(fruit: SODA.Item<Fruit>) {
        self.model = ViewModel(fruit: fruit)
    }
    
    var body: some View {
        Form {
            HStack {
                Text("Name").font(Font.body.bold())
                Spacer()
                Text(" \(model.fruit.value.name)")
            }
            HStack {
                Text("Count").font(Font.body.bold())
                Spacer()
                Text(" \(model.fruit.value.count)")
            }
            HStack {
                Text("Color").font(Font.body.bold())
                Spacer()
                Text(" \(model.fruit.value.color ?? "colorless")")
            }
        }
        .navigationTitle("Fruit details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: model.refreshFruit ) {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .disabled(model.isLoading)
            }
        }
    }
}

struct FruitView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FruitView(fruit:
                SODA.Item(
                    id: "0D856B76EC144C23AF116CD8DDE4B0BF",
                    etag: "711CBA3C074C421F99DA102F7C6EE74A",
                    lastModified: "2020-08-26T13:13:14.419586000Z",
                    created: "2020-08-26T09:20:27.891977000Z",
                    value: Fruit(name: "wild banana", count: 10, color: "bright yellow")
                )
            )
        }
    }
}
