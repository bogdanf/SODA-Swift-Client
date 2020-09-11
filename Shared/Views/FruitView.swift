//
//  FruitView.swift
//  SODA Client
//
//  Created by Bogdan Farca on 31/08/2020.
//

import SwiftUI

struct FruitView: View {
    
    @ObservedObject var model: ViewModel
    @State private var isEditing = false
    
    init(fruit: SODA.Item<Fruit>) {
        self.model = ViewModel(fruit: fruit)
    }
    
        
    
    var body: some View {
        Form {
            nameRow()
            countRow()
            colorRow()
            
            Section {
                Button(action: model.refreshFruit) {
                    Label("Refresh", systemImage: "arrow.up.arrow.down")
                }
                .disabled(model.isLoading || isEditing)
            }
        }
        .navigationTitle("Fruit details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        model.updateFruitOnServer()
                    }
                    isEditing.toggle()
                }
            }
        }
    }
    
    private func nameRow() -> some View {
        HStack {
            Text("Name").font(Font.body.bold())
            Spacer()
            if isEditing {
                TextField("name", text: $model.fruit.value.name)
                    .multilineTextAlignment(.trailing)
            } else {
                Text("\(model.fruit.value.name)")
            }
        }
    }
    
    private func countRow() -> some View {
        HStack {
            Text("Count").font(Font.body.bold())
            Spacer()
            if isEditing {
                TextField("item count", text: Binding(
                    get: { String(model.fruit.value.count) },
                    set: { model.fruit.value.count = Int($0) ?? 0 })
                )
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
            } else {
                Text("\(model.fruit.value.count)")
            }
        }
    }
    
    private func colorRow() -> some View {
        HStack {
            Text("Color").font(Font.body.bold())
            Spacer()
            if isEditing {
                TextField("color", text: Binding(
                            get: { String(model.fruit.value.color ?? "") },
                            set: { model.fruit.value.color = $0 == "" ? nil : $0 })
                )
                .multilineTextAlignment(.trailing)
            } else {
                Text(" \(model.fruit.value.color ?? "colorless")")
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
        .environment(\.editMode, Binding.constant(.active))
    }
}
