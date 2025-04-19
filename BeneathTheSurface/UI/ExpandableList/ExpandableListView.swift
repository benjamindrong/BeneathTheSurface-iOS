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
                    } onImageTapped: { url in
                        viewModel.selectedImageURL = url
                        viewModel.isShowingFullImage = true
                    }
                }
            }
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $viewModel.isShowingFullImage) {
            if let imageUrl = viewModel.selectedImageURL {
                FullScreenImageView(imageUrl: imageUrl) {
                    viewModel.isShowingFullImage = false
                }
            }
        }

    }
}
#Preview {
    ExpandableListView()
}
