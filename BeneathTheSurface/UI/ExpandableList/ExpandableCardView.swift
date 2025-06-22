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
                        .foregroundColor(fontTheme.textColor)
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
                    VStack(alignment: .leading, spacing: 8) {
                        if let pages = item.pages {
                            let page = pages[selectedPage]
                            
                            if let extract = page.extract {
                                Text(extract)
                                    .font(fontTheme.body)
                                    .fontWeight(.regular)
                                    .foregroundColor(fontTheme.textColor)
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
                            
                            // Page indicator + navigation
                            if pages.count > 1 {
                                HStack {
                                    Button(action: {
                                        if selectedPage > 0 {
                                            selectedPage -= 1
                                        }
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(selectedPage > 0 ? .primary : .gray)
                                    }
                                    .disabled(selectedPage == 0)
                                    
                                    Spacer()
                                    
                                    Text("\(selectedPage + 1) of \(pages.count)")
                                        .font(fontTheme.caption)
                                        .foregroundColor(fontTheme.textColor)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if selectedPage < pages.count - 1 {
                                            selectedPage += 1
                                        }
                                    }) {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(selectedPage < pages.count - 1 ? .primary : .gray)
                                    }
                                    .disabled(selectedPage == pages.count - 1)
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.clear)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        
    }
}
