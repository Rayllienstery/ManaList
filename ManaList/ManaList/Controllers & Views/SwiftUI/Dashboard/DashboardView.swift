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
                
            }
            .toolbar {
                Button {
                    store.send(.openShoppingLists)
                } label: {
                    Image(systemName: "list.triangle")
                }
            }
            .navigationTitle("Shopping Cart")
            .navigationDestination(item: $store.scope(state: \.shoppingLists, action: \.shoppingLists)) { store in
                ShoppingListsView(store: store)
            }
        }
    }
}

#Preview {
    DashboardView(store: .init(initialState: DashboardFeature.State(), reducer: {
        DashboardFeature()
    }))
}

@Reducer
struct DashboardFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var shoppingLists: ShoppingListsFeature.State?
    }

    enum Action: Sendable, BindableAction {
        case shoppingLists(PresentationAction<ShoppingListsFeature.Action>)
        case binding(BindingAction<State>)
        case openShoppingLists
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .shoppingLists(_):
                return .none
            case .binding(_):
                return .none
            case .openShoppingLists:
                state.shoppingLists = ShoppingListsFeature.State()
                return .none
            }
        }
        .ifLet(\.$shoppingLists, action: \.shoppingLists) {
            ShoppingListsFeature()
        }
    }
}
