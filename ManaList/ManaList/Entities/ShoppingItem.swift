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
    let id: UUID = UUID()
    var title: String
    var list: ShoppingList? = nil

    private(set) var isCompleted: Bool = false
    @Transient private var task: (Task<Bool, Error>)?

    init(title: String, list: ShoppingList?) {
        self.title = title
        self.list = list
    }

    @MainActor
    func checkAndDelete() async -> Bool {
        isCompleted.toggle()

        switch isCompleted {
        case true:
            task = .init(operation: {
                do {
                    try await Task.sleep(for: .seconds(2))
                    if isCompleted {
                        ModelContainer.current.mainContext.delete(self)
                        try ModelContainer.current.mainContext.save()
                        return true
                    } else {
                        return false
                    }
                } catch {
                    print(error.localizedDescription)
                    return false
                }
            })
        case false:
            task?.cancel()
            task = nil
            return false
        }

        let result: Bool = try! await task!.value
        return result
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
