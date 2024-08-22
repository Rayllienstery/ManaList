//
//  ManaListApp.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 16.08.2024.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct ManaListApp: App {
    var body: some Scene {
        // We should initialize shared before use sdContainer on the first launch
        let _ = PersistenceController.shared
        WindowGroup {
            DashboardView(store: .init(initialState: DashboardFeature.State(), reducer: {
                DashboardFeature()
            }))
            .modelContainer(PersistenceController.shared.sdContainer)
        }
    }
}
