//
//  TrailingButton.swift
//  ManaList
//
//  Created by Konstantin Kolosov on 22.08.2024.
//

import SwiftUI

struct TrailingButton: View {
    @State var title: String
    let onTap: () -> Void

    var body: some View {
        HStack {
            Divider()
            Button(title) {
                onTap()
            }
            .tint(Color(.label))
        }
    }
}
