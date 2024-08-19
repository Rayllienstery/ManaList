//
//  ContentView.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 16.08.2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct DashboardFeature {

//    @ObservableState
//    struct State: Equatable {
//        var counter = 50
//    }
    typealias State = DashboardState
    typealias Action = DashboardAction

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .increaseCounter:
                state.counter = min(100, state.counter + 5)
                return .none
            case .decreaseCounter:
                state.counter = max(0, state.counter - 5)
                return .none
            }
        }
    }
}

@ObservableState
struct DashboardState: Equatable {
    var counter = 50
}

enum DashboardAction: Equatable {
    case increaseCounter
    case decreaseCounter
}

struct DashboardView: View {
    let store: StoreOf<DashboardFeature>

    var body: some View {
        VStack {
            HStack {
                Button("-") {
                    store.send(.decreaseCounter)
                }
                ZStack {
                    let finishValue: CGFloat = min(1, CGFloat(store.counter) / 100)
                    VStack {
                        Text("\(store.counter)")
                    }
                    Circle()
                        .trim(from: 0, to: finishValue)
                        .stroke(lineWidth: 1.5)
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                        .animation(.snappy, value: finishValue)
                }
                Button("+") {
                    store.send(.increaseCounter)
                }
            }
        }
        .padding()
    }
}

#Preview {
    DashboardView(store: .init(initialState: DashboardFeature.State(), reducer: {
        DashboardFeature()
    }))
}
