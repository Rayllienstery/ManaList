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
    struct State: Sendable{
        @Presents var shoppingListsEditorDestination: ShoppingListsEditorFeature.State?
        @Presents var itemsEditorDestination: ShoppingListItemsEditorReducer.State?

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
        case itemsEditor(PresentationAction<ShoppingListItemsEditorReducer.Action>)
        case openShoppingLists
        case openItemsEditor(ShoppingList)

        case binding(BindingAction<State>)
        case fetchShoppingLists
        case updateLists([ShoppingList])
        case selectList(ShoppingList)
        case completeItemTap(ShoppingItem)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .shoppingLists(_), .itemsEditor(_):
                return .none
            case .binding(_):
                return .none
            case .fetchShoppingLists:
                return .run { send in
                    let lists = await ShoppingList.fetch()
                    await send(.updateLists(lists), animation: .bouncy)
                }
            case .updateLists(let lists):
                state.shoppingLists = lists
                return .none

            case .openShoppingLists:
                state.shoppingListsEditorDestination = ShoppingListsEditorFeature.State()
                return .none

            case .openItemsEditor(let list):
                state.itemsEditorDestination = ShoppingListItemsEditorReducer.State(selectedList: list)
                return .none

            case .selectList(let list):
                state.selectedShoppingList = list
                return .none

            case .completeItemTap(let item):
                return .run { send in
                    let result = await item.checkAndDelete()
                    if result {
                        await send(.fetchShoppingLists)
                    }
                }
            }
        }
        .ifLet(\.$shoppingListsEditorDestination, action: \.shoppingLists) {
            ShoppingListsEditorFeature()
        }
        .ifLet(\.$itemsEditorDestination, action: \.itemsEditor) {
            ShoppingListItemsEditorReducer()
        }
    }
}
