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
                                    print("Video done playing")
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

import SwiftUI
import AVKit

struct VideoLoadingIndicator: View {
    let isLoading: Bool
    let itemsLoaded: Bool
    let aiFinished: Bool
    let onVideoComplete: () -> Void

    @State private var player: AVPlayer?
    @State private var showVideo: Bool = true
    @State private var loadStarted: Bool = false
    @State private var hasPlayedAtLeastOnce: Bool = false
    @State private var shouldHideAfterCurrentLoop: Bool = false
    @State private var observerToken: NSObjectProtocol?

    // MARK: - Logic Flags
    var hasFinishedLoading: Bool {
        !isLoading && aiFinished && itemsLoaded
    }

    var body: some View {
        VStack {
            if showVideo, let player = player {
                VideoPlayer(player: player)
                    .frame(height: 200)
                    .onAppear {
                        configurePlayer()
                        if loadStarted {
                            playVideo()
                        }
                    }
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onChange(of: isLoading) { newValue in
            if newValue && !loadStarted {
                loadStarted = true
                playVideo()
            }
        }
        .onChange(of: hasFinishedLoading) { newValue in
            if newValue {
                // If video hasn't played once yet, mark to hide after it's done
                if hasPlayedAtLeastOnce {
                    stopAndHide()
                } else {
                    shouldHideAfterCurrentLoop = true
                }
            }
        }
        .onDisappear {
            cleanupObserver()
        }
    }

    // MARK: - Setup
    private func setupPlayer() {
        guard player == nil else { return }

        if let url = Bundle.main.url(forResource: "loading_animation", withExtension: "mov") {
            let item = AVPlayerItem(url: url)
            let avPlayer = AVPlayer(playerItem: item)
            avPlayer.actionAtItemEnd = .pause
            player = avPlayer

            observerToken = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { _ in
                hasPlayedAtLeastOnce = true

                if shouldHideAfterCurrentLoop || hasFinishedLoading {
                    stopAndHide()
                } else {
                    avPlayer.seek(to: .zero)
                    avPlayer.playImmediately(atRate: 1.0)
                }
            }

            // Show the paused video on initial load
            avPlayer.seek(to: .zero)
            avPlayer.pause()
        }
    }

    private func configurePlayer() {
        guard let player = player else { return }

        if !loadStarted {
            player.seek(to: .zero)
            player.pause()
        }
    }

    private func playVideo() {
        guard let player = player else { return }
        player.seek(to: .zero)
        player.playImmediately(atRate: 1.0)
    }

    private func stopAndHide() {
        player?.pause()
        showVideo = false
        onVideoComplete()
    }

    private func cleanupObserver() {
        if let token = observerToken {
            NotificationCenter.default.removeObserver(token)
            observerToken = nil
        }
    }
}


