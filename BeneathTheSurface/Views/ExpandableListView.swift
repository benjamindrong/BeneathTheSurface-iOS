//
//  ExpandableListView.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/15/25.
//

import SwiftUI

struct ExpandableListView: View {
    @StateObject private var viewModel = ExpandableListViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.items) { item in
                    ExpandableCardView(item: item) {
                        viewModel.toggleItem(item)
                    }
                }
            }
            .padding(.horizontal)
        }

    }
}
#Preview {
    ExpandableListView()
}
