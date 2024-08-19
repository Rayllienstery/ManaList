//
//  ShoppingListsTabView.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 19.08.2024.
//

import SwiftUI

struct ShoppingListsTabView: View {
    @Binding var lists: [ShoppingList]
    @Binding var selectedListId: UUID
    @Binding var summaryList: ShoppingList

    @State var onTap: (ShoppingList) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            ZStack {
                HStack(spacing: 8) {
                    TabView(list: summaryList)
                    ForEach(lists) {
                        TabView(list: $0)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private func TabView(list: ShoppingList) -> some View {
        let isSelected = list.id == selectedListId
        ZStack {
            Text(list.title)
                .foregroundStyle(isSelected ? Color(.systemBackground) : Color(.label))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .foregroundStyle(isSelected ? Color(.label) : Color(.lightGray.withAlphaComponent(0.3)))
        }
        .scaleEffect(isSelected ? 1.00 : 0.93)
        .animation(.spring(duration: isSelected ? 0.37 : 0, bounce: 0.5), value: isSelected ? 2.5 : 0.9)
        .onTapGesture {
            onTap(list)
        }
    }
}

#Preview {
    struct ShoppingListsTabPreview: View {
        @State var lists: [ShoppingList]
        @State var selectedId: UUID
        @State var summary: ShoppingList

        init(lists: [ShoppingList]) {
            let summaryList = ShoppingList(title: "Summary", isSummary: true)
            self.lists = lists
            self.summary = summaryList
            self.selectedId = summaryList.id
        }

        var body: some View {
            NavigationStack {
                List {
                    Section {
                        ForEach(0..<5) {
                            Text("List item \($0)")
                        }
                    } header: {
                        ShoppingListsTabView(lists: $lists, 
                                             selectedListId: $selectedId,
                                             summaryList: $summary) { list in
                            selectedId = list.id
                        }
                        .textCase(nil)
                        .padding(.horizontal, -40)
                        .padding(.bottom, 16)
                    }
                }
                .navigationTitle("Shopping Tab View")
            }
        }
    }

    let lists = ShoppingList.stabData()
    return ShoppingListsTabPreview(lists: lists)
}
