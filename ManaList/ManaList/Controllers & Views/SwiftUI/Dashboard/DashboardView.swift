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
                Section { } header: {
                    ShoppingListsTabView(lists: $store.shoppingLists,
                                         selectedListId: $store.selectedShoppingListId,
                                         summaryList: $store.summaryList) { selectedList in
                        store.send(.selectList(selectedList))
                    }
                    .textCase(nil)
                    .padding(.horizontal, -40)
                    .padding(.bottom, 16)
                }
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
                ShoppingListsView(store: store)
            }
            .task {
                store.send(.fetchShoppingLists)
            }
        }
    }
}

#Preview {
    DashboardView(store: .init(initialState: DashboardFeature.State(), reducer: {
        DashboardFeature()
    }))
}
