//
//  ShoppingListItemsEditorReducer.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 20.08.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ShoppingListItemsEditorReducer {
    @ObservableState
    struct State: Sendable, Equatable {
        var newItemTitle: String = ""

        var selectedList: ShoppingList

        var newItems: [ShoppingItem] = []
        var shoppingLists: [ShoppingList] = []

        init(selectedList: ShoppingList) {
            self.selectedList = selectedList
        }
    }

    enum Action: Sendable, BindableAction {
        case binding(BindingAction<State>)
        
        case fetchLists
        case updateLists([ShoppingList])
        case selectList(ShoppingList)
        case addNewItem
        case doneTap
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .fetchLists:
                return .run { send in
                    let lists = await ShoppingList.fetch()
                    await send(.updateLists(lists))
                }
            case .updateLists(let lists):
                state.shoppingLists = lists
                return .none
            case .selectList(let list):
                state.selectedList = list
                return .none
            case .addNewItem:
                state.newItems.append(.init(title: state.newItemTitle, list: nil))
                state.newItemTitle.removeAll()
                return .none
            case .doneTap:
                return .none
            case .binding(_): return .none
            }
        }
    }
}
