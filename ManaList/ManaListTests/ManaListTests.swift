//
//  ManaListTests.swift
//  ManaListTests
//
//  Created by Konstantin Kolosov on 16.08.2024.
//

import XCTest
@testable import ManaList
import SwiftData

final class ManaListTests: XCTestCase {
    let container: ModelContainer = PersistenceController(inMemory: true).sdContainer

    @MainActor override func tearDown() {
        let lists = ShoppingList.fetch(container: container)
        lists.forEach({ $0.delete() })
    }

    @MainActor func testFetch() throws {
        let titleList = (0..<5).map({ "Just a title \($0)" })
        do {
            for title in titleList {
                try ShoppingList.insert(title: title, container: container)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }

        let lists = ShoppingList.fetch(container: container)

        XCTAssertTrue(lists.count == 5)
    }

    @MainActor func testTitle_CorrectData() throws {
        do {
            let title = "Title"
            // Create a new list
            try ShoppingList.insert(title: title, container: container)

            // Fetch it
            let lists = ShoppingList.fetch(container: container)
            guard let list = lists.first else { XCTFail(); return }

            // Lists count should be 1, this single list should have "Title" as a title
            XCTAssertTrue(lists.count == 1 && list.title == title)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    @MainActor func testTitle_IncorrectData() throws {
        do {
            let title = ""
            // Create a new list
            try ShoppingList.insert(title: title, container: container)
            XCTFail()
        } catch {
            XCTAssertTrue(error.localizedDescription ==
                          ShoppingListsError.missingTitle.localizedDescription)
        }
    }

    @MainActor func testDelete() {
        do {
            let title1 = "title1"
            let title2 = "title2"

            try ShoppingList.insert(title: title1, container: container)
            try ShoppingList.insert(title: title2, container: container)

            let lists = ShoppingList.fetch(container: container)
            lists[0].delete(container: container)

            let updatedListsAfterDelete = ShoppingList.fetch(container: container)
            XCTAssertTrue(updatedListsAfterDelete.count == 1, "\(updatedListsAfterDelete.map({$0.title}))")
        } catch {
            XCTFail()
        }
    }
}
