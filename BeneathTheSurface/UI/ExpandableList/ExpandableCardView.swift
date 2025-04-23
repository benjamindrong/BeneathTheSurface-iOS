//
//  ExpandableCardView.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/15/25.
//

import SwiftUI

struct ExpandableCardView: View {
    var item: ExpandableItem
    var onToggle: () -> Void
    var onImageTapped: (URL) -> Void
    @State private var selectedPage = 0
    @State private var isShowingFullImage = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.title)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(item.isExpanded ? 180 : 0))
                    .animation(.easeInOut(duration: 0.25), value: item.isExpanded)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    onToggle()
                }
            }

            if item.isExpanded {
                TabView(selection: $selectedPage) {
                    ForEach(Array((item.pages?.enumerated())!), id: \.element.pageID) { index, page in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                if let extract = page.extract {
                                    Text(extract)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                if let imageUrl = page.thumbnail?.source, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(10)
                                                .onTapGesture {
                                                    if let original = page.originalImage?.source,
                                                           let url = URL(string: original) {
                                                            onImageTapped(url)
                                                        }
                                                }
                                        case .failure:
                                            Image(systemName: "photo")
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(height: 150)
                                }
                            }
                            .padding()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 300)

                // Page indicator
                HStack {
                    Spacer()
                    Text("\(selectedPage + 1) of \(item.pages?.count ?? 1)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
