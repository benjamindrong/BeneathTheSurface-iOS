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

    @Environment(\.fontTheme) var fontTheme
    
    var body: some View {
        ZStack {
            // Dynamically sized background overlay
            GeometryReader { geometry in
                Image("result_overlay")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.25)
                    .clipped()
                    .cornerRadius(10)
            }

            // Content sits on top of overlay
            VStack(alignment: .leading) {
                HStack {
                    Text(item.title)
                        .font(fontTheme.title)
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
                                            .font(fontTheme.title)
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

                    HStack {
                        Spacer()
                        Text("\(selectedPage + 1) of \(item.pages?.count ?? 1)")
                            .font(fontTheme.caption)
                        Spacer()
                    }
                }
            }
            .padding()
        }
        .background(Color.clear)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

}
