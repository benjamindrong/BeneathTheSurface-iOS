//
//  ExpandableListView.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/15/25.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI

struct ExpandableListView: View {
    @StateObject private var viewModel = ExpandableListViewModel()
    
    @Environment(\.colorTheme) var colorTheme
    @Environment(\.fontTheme) var fontTheme
    
    var body: some View {
        ZStack {
            colorTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    OnThisDayFormView { day, month, year in
                        viewModel.loadData(month: month, day: day)
                    }
                    
                    VideoLoadingIndicator(
                                    isLoading: viewModel.isLoading,
                                    itemsLoaded: !viewModel.items.isEmpty,
                                    aiFinished: viewModel.aiLoadingComplete
                                ) {
                                    // Called after video finishes
                                    print("🔁 Video done playing")
                                }
                    
                    ForEach(viewModel.items) { item in
                        ExpandableCardView(item: item) {
                            viewModel.toggleItem(item)
                        } onImageTapped: { url in
                            viewModel.selectedImageURL = url
                            viewModel.isShowingFullImage = true
                        }
                        .background(colorTheme.surface)
                    }
                }
                .padding(.horizontal)
            }

//            if viewModel.isLoading {
//                VStack {
//                    ProgressView("Loading...")
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .scaleEffect(2)
//                        .font(fontTheme.title)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color(.systemBackground).opacity(0.8))
//                .edgesIgnoringSafeArea(.all)
//                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
//            }
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

struct VideoPlaceholderView: View {
    @State private var player: AVPlayer? = nil

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if player == nil {
                    if let url = Bundle.main.url(forResource: "loading_animation", withExtension: "mov") {
                        let playerItem = AVPlayerItem(url: url)
                        let avPlayer = AVPlayer(playerItem: playerItem)
                        avPlayer.actionAtItemEnd = .pause
                        avPlayer.seek(to: .zero) // Seek to start
                        avPlayer.pause()
                        self.player = avPlayer
                    }
                }
            }
            .frame(height: 200)
    }
}

import SwiftUI
import AVKit

struct VideoLoadingIndicator: View {
    let isLoading: Bool
    let itemsLoaded: Bool
    let aiFinished: Bool
    let onVideoComplete: () -> Void

    @State private var player: AVPlayer?
    @State private var showVideo: Bool = true
    @State private var observerToken: NSObjectProtocol?

    var shouldBeVisible: Bool {
        isLoading || !aiFinished || !itemsLoaded
    }

    var shouldPlay: Bool {
        isLoading || !aiFinished
    }

    var body: some View {
        VStack {
            if showVideo {
                if let player = player {
                    VideoPlayer(player: player)
                        .onAppear {
                            configurePlayback()
                        }
                        .frame(height: 200)
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onChange(of: shouldBeVisible) { newValue in
            if !newValue {
                player?.pause()
                showVideo = false
                onVideoComplete()
            } else {
                showVideo = true
                configurePlayback()
            }
        }
        .onDisappear {
            cleanupObserver()
        }
    }

    private func setupPlayer() {
        guard player == nil else { return }

        if let url = Bundle.main.url(forResource: "loading_animation", withExtension: "mov") {
            let item = AVPlayerItem(url: url)
            let avPlayer = AVPlayer(playerItem: item)
            avPlayer.actionAtItemEnd = .none
            avPlayer.rate = 0.0
            player = avPlayer
        }
    }

    private func configurePlayback() {
        guard let player = player else { return }

        if observerToken == nil {
            observerToken = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                if shouldPlay {
                    player.seek(to: .zero)
                    player.playImmediately(atRate: 2.0)
                }
            }
        }

        if shouldPlay {
            player.seek(to: .zero)
            player.playImmediately(atRate: 2.0)
        } else {
            player.seek(to: .zero)
            player.pause()
        }
    }

    private func cleanupObserver() {
        if let token = observerToken {
            NotificationCenter.default.removeObserver(token)
            observerToken = nil
        }
    }
}
