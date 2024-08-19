//
//  ShoppingListsView.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 16.08.2024.
//

import SwiftUI
import ComposableArchitecture

struct ShoppingListsEditorView: View {
    @Bindable var store: StoreOf<ShoppingListsFeature>

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("Use swipe gesture to delete a List",
                              systemImage: "hand.point.up.left.and.text.fill")
                            .foregroundStyle(.primary)
                    }
                }
                if store.shoppingLists.count > 0 {
                    Section {
                        ForEach(store.shoppingLists) { list in
                            Text(list.title)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        store.send(.delete(list))
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                        }
                    } header: {
                        Text("Lists")
                    }
                }
                Section {
                    TextField("Start typing here...", text: $store.listTitle)
                    Button("Insert List") {
                        store.send(.createList)
                    }
                } header: {
                    Text("Create a new list here")
                }
            }
            .navigationTitle("Shopping Lists")
            .task {
                store.send(.fetchShoppingLists)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    ShoppingListsEditorView(store: Store(initialState: ShoppingListsFeature.State(),
                                         reducer: { ShoppingListsFeature() }))
    .modelContainer(.current)
}

@Reducer
struct ShoppingListsFeature {
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
