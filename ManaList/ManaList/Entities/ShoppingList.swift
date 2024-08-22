//
//  ShoppingList.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 17.08.2024.
//

import Foundation
import SwiftData

@Model
final class ShoppingList: Sendable, Identifiable, Equatable {
    static let summaryList = ShoppingList(title: "Summary", isSummary: true)

    var id: UUID = UUID()
    var title: String
    var items: [ShoppingItem] = []
    var isSummary: Bool = false

    init(title: String) {
        self.title = title
    }

    private init(title: String, isSummary: Bool) {
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
    static func stubArray(container: ModelContainer = PersistenceController.init(inMemory: true).sdContainer) -> [ShoppingList] {
        let lists = (0..<5).map({ ShoppingList(title: "Stab \($0)") })
        lists.forEach({ container.mainContext.insert($0) })
        try! container.mainContext.save()
        return lists
    }

    @MainActor
    static func stubObject() -> ShoppingList {
        let container = PersistenceController.init(inMemory: true).sdContainer
        let stabObject = ShoppingList(title: "Stab Object")
        container.mainContext.insert(stabObject)
        try! container.mainContext.save()
        return stabObject
    }
}
