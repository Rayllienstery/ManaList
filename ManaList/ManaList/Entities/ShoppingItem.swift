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
