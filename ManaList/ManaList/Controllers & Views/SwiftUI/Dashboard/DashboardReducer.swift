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
        @Presents var shoppingListsEditorDestination: ShoppingListsFeature.State?
        var shoppingLists: [ShoppingList] = []
        var summaryList: ShoppingList
        var selectedShoppingListId: UUID

        init() {
            let summaryListMock = ShoppingList(title: "Summary", isSummary: true)
            self.summaryList = summaryListMock
            self.selectedShoppingListId = summaryListMock.id
        }
    }

    enum Action: Sendable, BindableAction {
        case shoppingLists(PresentationAction<ShoppingListsFeature.Action>)
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
                if !lists.isEmpty,
                   !lists.map({ $0.id }).contains(state.selectedShoppingListId) {
                    state.selectedShoppingListId = lists[0].id
                }
                return .none

            case .openShoppingLists:
                state.shoppingListsEditorDestination = ShoppingListsFeature.State()
                return .none

            case .selectList(let list):
                state.selectedShoppingListId = list.id
                return .none
            }
        }
        .ifLet(\.$shoppingListsEditorDestination, action: \.shoppingLists) {
            ShoppingListsFeature()
        }
    }
}
