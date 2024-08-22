//
//  ContentView.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 16.08.2024.
//

import SwiftUI
import ComposableArchitecture

struct DashboardView: View {
    @Bindable var store: StoreOf<DashboardFeature>

    var body: some View {
        NavigationStack {
            List {
                headerTabView
                contentView
            }
            .toolbar {
                Button {
                    store.send(.openShoppingLists)
                } label: {
                    Image(systemName: "list.triangle")
                }
            }
            .navigationTitle("Shopping Cart")
            .navigationDestination(item: $store.scope(state: \.shoppingListsEditorDestination, action: \.shoppingLists)) { store in
                ShoppingListsEditorView(store: store)
            }
            .sheet(item: $store.scope(state: \.itemsEditorDestination, action: \.itemsEditor)) { store in
                NavigationStack {
                    ShoppingListItemsEditorView(store: store)
                }
            }
            .task {
                store.send(.fetchShoppingLists)
            }
        }
    }

    @ViewBuilder
    private var headerTabView: some View {
        Section { } header: {
            ShoppingListsTabView(lists: $store.shoppingLists,
                                 selectedListId: $store.selectedShoppingList.id,
                                 summaryList: $store.summaryList) { selectedList in
                store.send(.selectList(selectedList))
            }
            .textCase(nil)
            .padding(.horizontal, -40)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch store.selectedShoppingList === ShoppingList.summaryList {
        case true:
            ForEach(store.shoppingLists) { listSection(for: $0, withHeader: true) }
        case false:
            listSection(for: store.selectedShoppingList, withHeader: false)
        }
    }

    @ViewBuilder
    private func listSection(for list: ShoppingList, withHeader: Bool) -> some View {
        Section {
            ForEach(list.items) { item in
                Text(item.title)
            }
        } header: {
            if withHeader {
                Text(list.title)
            }
        } footer: {
            Button {
                store.send(.openItemsEditor(list))
            } label: {
                VStack(alignment: .leading) {
                    if list.items.isEmpty {
                        Divider()
                    }
                    Label("Add Item", systemImage: "plus")
                        .foregroundStyle(Color(.secondaryLabel))
                        .font(.callout)
                }
            }
        }
    }
}

#Preview {
    PersistenceController.shared = PersistenceController.init(inMemory: true)
    _ = ShoppingList.stubArray(container: .current)
    return DashboardView(store: .init(initialState: DashboardFeature.State(), reducer: {
        DashboardFeature()
    }))
    .modelContainer(.current)
}
