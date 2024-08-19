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

    init(title: String) {
        self.title = title
    }
}
