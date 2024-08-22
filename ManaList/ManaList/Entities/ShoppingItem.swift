//
//  ShoppingItem.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 19.08.2024.
//

import Foundation
import SwiftData

@Model
final class ShoppingItem: Sendable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var list: ShoppingList? = nil

    init(title: String, list: ShoppingList?) {
        self.title = title
        self.list = list
    }
}

extension ShoppingItem {
    @MainActor
    static func stubArray(list: ShoppingList, container: ModelContainer = PersistenceController.init(inMemory: true).sdContainer) -> [ShoppingItem] {
        let lists = (0..<5).map({ ShoppingItem(title: "SI Stub \($0)", list: list) })
        lists.forEach({ container.mainContext.insert($0) })
        try! container.mainContext.save()
        return lists
    }
}
