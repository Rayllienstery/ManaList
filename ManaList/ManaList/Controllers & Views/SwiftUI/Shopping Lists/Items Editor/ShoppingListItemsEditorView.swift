//
//  ShoppingListItemsEditorView.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 20.08.2024.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

struct ShoppingListItemsEditorView: View {
    @State var store: StoreOf<ShoppingListItemsEditorReducer>

    var body: some View {
        List {
            listSelectorView
            newItemsSection
        }
        .task {
            store.send(.fetchLists)
        }
        .navigationTitle("New Items")
    }

    @ViewBuilder
    private var listSelectorView: some View {
        Section {
            HStack {
                Text(store.selectedList.title)
                Spacer()
                Menu {
                    ForEach(store.shoppingLists) { shoppingList in
                        Button(shoppingList.title) {
                            
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down")
                }
            }
            .tint(Color(.label))
        } header: {
            Text("Selected List")
        }
    }

    @ViewBuilder
    private var newItemsSection: some View {
        Section {
            ForEach(store.newItems) {
                Text($0.title)
            }
        }
        Section {
            TextField("Start typing here...", text: $store.newItemTitle)
            Button("Add") { store.send(.addNewItem) }
        } header: {
            Text("Add a new items")
        }
    }
}

#Preview {
    struct ShoppingListItemsEditorViewWrapper: View {
        var body: some View {
            NavigationStack {
                ShoppingListItemsEditorView(
                    store: Store(initialState: ShoppingListItemsEditorReducer.State(selectedList: .stubObject()),
                                 reducer: { ShoppingListItemsEditorReducer() }))
            }
        }
    }

    PersistenceController.shared = PersistenceController.init(inMemory: true)
    _ = ShoppingList.stubArray(container: .current)
    let lists = try? ModelContainer.current.mainContext.fetch(FetchDescriptor<ShoppingList>())
    
    return ShoppingListItemsEditorViewWrapper()
        .modelContainer(.current)
}
