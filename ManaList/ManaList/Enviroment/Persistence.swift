//
//  Persistence.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 17.08.2024.
//

import SwiftData

protocol Persistence {
    // SwiftData Managed Container
    var sdContainer: ModelContainer { get }
}

struct PersistenceController: Persistence {
    static var shared: Persistence = PersistenceController()

    var sdContainer: ModelContainer

    init(inMemory: Bool = false) {
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        let swiftDataContainer = try! ModelContainer(
            for: ShoppingList.self,
            configurations: config)
        self.sdContainer = swiftDataContainer
    }
}

extension ModelContainer {
    static var current: ModelContainer { return PersistenceController.shared.sdContainer }
}
