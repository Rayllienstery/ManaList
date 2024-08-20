//
//  ShoppingListsEditorFeature.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 20.08.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ShoppingListsEditorFeature {
    @ObservableState
    struct State: Equatable {
        var shoppingLists: [ShoppingList] = []
        var listTitle: String = ""

        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action: Sendable, ViewAction {
        case fetchShoppingLists
        case updateLists([ShoppingList])
        case createList
        case cleanTitle
        case delete(ShoppingList)

        case view(View)
        case error(Error)
        case alert(PresentationAction<Alert>)
        enum Alert: Equatable, Sendable {}

        @CasePathable
        enum View: BindableAction, Sendable {
          case binding(BindingAction<State>)
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .fetchShoppingLists:
                return .run { send in
                    let lists = await ShoppingList.fetch()
                    await send(.updateLists(lists))
                }

            case .updateLists(let lists):
                state.shoppingLists = lists
                return .none

            case .createList:
                let newTitle = state.listTitle
                return .run { send in
                    do {
                        try await ShoppingList.insert(title: newTitle)
                        await send(.cleanTitle)
                        await send(.fetchShoppingLists)
                    } catch {
                        throw error
                    }
                } catch: { error, send in
                    await send(.error(error))
                }

            case .view(.binding(_)):
                return .none

            case .cleanTitle:
                state.listTitle = ""
                return .none

            case .delete(let list):
                return .run { send in
                    await list.delete()
                    await send(.fetchShoppingLists)
                }

            case .error(let error):
                state.alert = AlertState { TextState(error.localizedDescription) }
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

enum ShoppingListsError: LocalizedError, Equatable {
    case missingTitle

    var errorDescription: String? {
        switch self {
        case .missingTitle: "Enter title, please"
        }
    }
}
