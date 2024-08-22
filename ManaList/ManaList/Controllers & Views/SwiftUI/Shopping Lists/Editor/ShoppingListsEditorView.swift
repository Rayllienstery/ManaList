//
//  ShoppingListsView.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 16.08.2024.
//

import SwiftUI
import ComposableArchitecture

struct ShoppingListsEditorView: View {
    @Bindable var store: StoreOf<ShoppingListsEditorFeature>

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("Use swipe gesture to delete a List",
                              systemImage: "hand.point.up.left.and.text.fill")
                            .foregroundStyle(.primary)
                    }
                }
                if store.shoppingLists.count > 0 {
                    Section {
                        ForEach(store.shoppingLists) { list in
                            Text(list.title)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        store.send(.delete(list))
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                        }
                    } header: {
                        Text("Lists")
                    }
                }
                Section {
                    HStack {
                        TextField("Start typing here...", text: $store.listTitle)
                            .submitLabel(.done)
                            .onSubmit {
                                store.send(.createList)
                            }
                        Spacer()
                        if !store.listTitle.isEmpty {
                            TrailingButton(title: "Insert") { store.send(.createList) }
                        }
                    }
                } header: {
                    Text("Create a new list here")
                }
            }
            .navigationTitle("Shopping Lists")
            .task {
                store.send(.fetchShoppingLists)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    ShoppingListsEditorView(store: Store(initialState: ShoppingListsEditorFeature.State(),
                                         reducer: { ShoppingListsEditorFeature() }))
    .modelContainer(.current)
}
