//
//  FullScreenImageView.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/17/25.
//

import SwiftUI

struct FullScreenImageView: View {
    let imageUrl: URL
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .scaleEffect(1.5)
                        .foregroundColor(.white)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()

                case .failure:
                    Image(systemName: "photo.fill")
                        .foregroundColor(.gray)

                @unknown default:
                    EmptyView()
                }
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

