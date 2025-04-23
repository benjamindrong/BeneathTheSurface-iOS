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
        ZStack {
            ScrollView {
                VStack(spacing: 12) {
                    OnThisDayFormView { day, month in
                        viewModel.loadData(month: month, day: day)
                    }
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

            if viewModel.isLoading {
                VStack {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.8))
                .edgesIgnoringSafeArea(.all)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            }
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
