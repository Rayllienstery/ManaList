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
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            listSelectorView
            newItemsSection
        }
        .task {
            store.send(.fetchLists)
        }
        .navigationTitle("Add Items")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { store.send(.doneTap) }
                    .onChange(of: store.isPresented) { _, newValue in
                        if !newValue { dismiss() }
                    }
            }
        }
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
            HStack {
                TextField("Start typing here...", text: $store.newItemTitle)
                    .submitLabel(.done)
                    .onSubmit { store.send(.addNewItem) }
                Spacer()
                if !store.newItemTitle.isEmpty {
                    TrailingButton(title: "Add") { store.send(.addNewItem) }
                }
            }
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

    struct ModalWrapper: View {
        @State var isPresented = true

        var body: some View {
            Button("Present"){ isPresented = true }
                .sheet(isPresented: $isPresented, content: {
                ShoppingListItemsEditorViewWrapper()
                    .modelContainer(.current)
            })
        }
    }
    return ModalWrapper()
}
