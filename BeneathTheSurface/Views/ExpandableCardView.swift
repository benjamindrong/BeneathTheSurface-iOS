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
            .contentShape(Rectangle()) // Makes entire row tappable
            .onTapGesture {
                withAnimation {
                    onToggle()
                }
            }

            if item.isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(item.children, id: \.self) { child in
                        Text(child)
                            .padding(.leading, 8)
                            .font(.subheadline)
                    }
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
