//
//  FruitView.swift
//  SODA Client
//
//  Created by Bogdan Farca on 31/08/2020.
//

import SwiftUI

struct FruitView: View {
    
    @EnvironmentObject private var dataStore: DataStore
    
    @State private var fruit: SODA.Item<Fruit>
    @State private var isEditing: Bool
    
    init(fruit: SODA.Item<Fruit>?) {
        self.fruit = fruit ?? SODA.Item(id: "", etag: "", lastModified: "", created: "", value: Fruit())
        
        // Entering Edit mode if it's a new Fruit
        isEditing = fruit == nil
    }
    
    var body: some View {
        Form {
            nameRow()
            countRow()
            colorRow()
            
            Section {
                Button() {
                    async { fruit.value = await dataStore.refresh(fruit: fruit) }
                } label: {
                    Label("Refresh", systemImage: "arrow.up.arrow.down")
                }
                .disabled(dataStore.isLoading || isEditing)
            }
        }
        .navigationTitle("Fruit details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        async {
                            fruit = await dataStore.addOrUpdate(fruit: fruit)
                            isEditing = false
                        }
                    } else {
                        isEditing = true
                    }
                }.disabled(dataStore.isLoading)
            }
        }
    }
    
    private func nameRow() -> some View {
        HStack {
            Text("Name").font(Font.body.bold())
            Spacer()
            if isEditing {
                TextField("name", text: $fruit.value.name)
                    .multilineTextAlignment(.trailing)
            } else {
                Text("\(fruit.value.name)")
            }
        }
    }
    
    private func countRow() -> some View {
        HStack {
            Text("Count").font(Font.body.bold())
            Spacer()
            if isEditing {
                TextField("item count", text: Binding(
                    get: { String(fruit.value.count) },
                    set: { fruit.value.count = Int($0) ?? 0 })
                )
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
            } else {
                Text("\(fruit.value.count)")
            }
        }
    }
    
    private func colorRow() -> some View {
        HStack {
            Text("Color").font(Font.body.bold())
            Spacer()
            if isEditing {
                TextField("color", text: Binding(
                            get: { String(fruit.value.color ?? "") },
                            set: { fruit.value.color = $0 == "" ? nil : $0 })
                )
                .multilineTextAlignment(.trailing)
            } else {
                Text(" \(fruit.value.color ?? "colorless")")
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
        .environmentObject(DataStore())
    }
}
