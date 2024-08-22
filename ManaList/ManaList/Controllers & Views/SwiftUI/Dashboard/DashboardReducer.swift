//
//  DashboardReducer.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 19.08.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DashboardFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var shoppingListsEditorDestination: ShoppingListsEditorFeature.State?

        var shoppingLists: [ShoppingList] = []
        var summaryList: ShoppingList
        var selectedShoppingList: ShoppingList

        init() {
            self.summaryList = ShoppingList.summaryList
            self.selectedShoppingList = ShoppingList.summaryList
        }
    }

    enum Action: Sendable, BindableAction {
        case shoppingLists(PresentationAction<ShoppingListsEditorFeature.Action>)
        case binding(BindingAction<State>)
        case fetchShoppingLists
        case openShoppingLists
        case updateLists([ShoppingList])
        case selectList(ShoppingList)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .shoppingLists(_):
                return .none
            case .binding(_):
                return .none
            case .fetchShoppingLists:
                return .run { send in
                    let lists = await ShoppingList.fetch()
                    await send(.updateLists(lists))
                }
            case .updateLists(let lists):
                state.shoppingLists = lists
                return .none

            case .openShoppingLists:
                state.shoppingListsEditorDestination = ShoppingListsEditorFeature.State()
                return .none

            case .selectList(let list):
                state.selectedShoppingList = list
                return .none
            }
        }
        .ifLet(\.$shoppingListsEditorDestination, action: \.shoppingLists) {
            ShoppingListsEditorFeature()
        }
    }
}
