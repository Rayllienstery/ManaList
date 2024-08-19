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
    var items: [ShoppingItem] = []
    var isSummary: Bool = false

    init(title: String, isSummary: Bool = false) {
        self.title = title
        self.isSummary = isSummary
    }

    @MainActor
    static func insert(title: String, container: ModelContainer = .current) throws {
        guard !title.isEmpty else { throw ShoppingListsError.missingTitle }
        let newList = ShoppingList(title: title)
        container.mainContext.insert(newList)
        try? container.mainContext.save()
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
        try? container.mainContext.save()
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
