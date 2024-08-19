//
//  ShoppingList.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 17.08.2024.
//

import Foundation
import SwiftData

@Model
final class ShoppingList: Sendable, Identifiable {
    var id: UUID = UUID()
    var title: String

    private init(title: String) {
        self.title = title
    }

    @MainActor
    static func insert(title: String, container: ModelContainer = .current) throws {
        guard !title.isEmpty else { throw ShoppingListsError.missingTitle }
        let newList = ShoppingList(title: title)
        container.mainContext.insert(newList)
    }

    @MainActor 
    static func fetch(container: ModelContainer = .current) -> [ShoppingList] {
        do {
            return try container.mainContext.fetch(FetchDescriptor<ShoppingList>())
        } catch {
            fatalError("ShoppingList: \(error.localizedDescription)")
        }
    }

    @MainActor
    func delete(container: ModelContainer = .current) {
        container.mainContext.delete(self)
    }
}

extension ShoppingList {
    @MainActor
    static func stabData() -> [ShoppingList] {
        let container = PersistenceController.init(inMemory: true).sdContainer
        let lists = (0..<5).map({ ShoppingList(title: "Stab \($0)") })
        lists.forEach({ container.mainContext.insert($0) })
        return lists
    }
}
