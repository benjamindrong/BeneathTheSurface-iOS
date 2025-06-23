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
            
            VStack(spacing: 0) {
                OnThisDayFormView { day, month, year in
                    viewModel.loadData(month: month, day: day)
                }
                .background(colorTheme.surface)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 12) {
                        VideoLoadingIndicator(
                            isLoading: viewModel.isLoading,
                            itemsLoaded: !viewModel.items.isEmpty,
                            aiFinished: viewModel.aiLoadingComplete,
                            onVideoComplete: {
                                viewModel.isVideoDonePlaying = true
                            },
                            resetTrigger: viewModel.videoResetTrigger
                        )

                        if viewModel.isDataShowing && viewModel.isVideoDonePlaying {
                            ForEach(viewModel.items) { item in
                                ExpandableCardView(item: item) {
                                    viewModel.toggleItem(item)
                                } onImageTapped: { url in
                                    viewModel.selectedImageURL = url
                                    viewModel.isShowingFullImage = true
                                }
                                .background(colorTheme.surface)
                                .cornerRadius(10)
                            }
                        }
                    }
//                    .padding(.horizontal)
                }
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
//            .frame(height: 200)
    }
}

import SwiftUI
import AVKit

import SwiftUI
import AVKit

import SwiftUI
import AVKit

struct VideoLoadingIndicator: View {
    let isLoading: Bool
    let itemsLoaded: Bool
    let aiFinished: Bool
    let onVideoComplete: () -> Void
    let resetTrigger: UUID

    @State private var player: AVPlayer?
    @State private var showVideo: Bool = false
    @State private var hasPlayedOnce: Bool = false
    @State private var shouldStopAfterFirstLoop: Bool = false
    @State private var observerToken: NSObjectProtocol?
    @State private var timeObserverToken: Any?

    var dataFinishedLoading: Bool {
        !isLoading && aiFinished && itemsLoaded
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack {
                if showVideo, let player = player {
                    let width = geometry.size.width - 32 // Add some horizontal margin
                    let aspectRatio: CGFloat = 900 / 720
                    let height = width * aspectRatio

                    ScaledVideoPlayer(player: player)
                        .frame(width: width, height: height)
                        .clipped()
                        .cornerRadius(12) // Optional, for clean edges
                        .padding(.horizontal, 16) // Ensures it doesn’t touch screen edges
                }
            }
        }

        .onAppear {
            setupPlayerIfNeeded()
        }
        .onChange(of: isLoading) { newValue in
            if newValue {
                showAndPlay()
            }
        }
        .onChange(of: resetTrigger) { _ in
            resetState()
        }
        .onChange(of: dataFinishedLoading) { finished in
            if finished && hasPlayedOnce {
                stopAndHide()
            } else if finished {
                shouldStopAfterFirstLoop = true
            }
        }
        .onDisappear {
            cleanupObserver()
        }
    }

    private func setupPlayerIfNeeded() {
        
        guard player == nil else { return }

        if let url = Bundle.main.url(forResource: "loading_animation", withExtension: "mov") {
            let item = AVPlayerItem(url: url)
            let avPlayer = AVPlayer(playerItem: item)
            avPlayer.actionAtItemEnd = .pause
            player = avPlayer
            
            // Observe playback progress
            let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
                let seconds = CMTimeGetSeconds(time)
                
                // Change speed after 2 seconds (adjust as needed)
                if seconds >= 1 && avPlayer.rate < 2.0 {
                    avPlayer.rate = 2
                }
            }


            observerToken = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { _ in
                handlePlaybackFinished()
            }

            avPlayer.seek(to: .zero)
            avPlayer.pause()
        }
    }

    private func showAndPlay() {
        showVideo = true
        hasPlayedOnce = false
        shouldStopAfterFirstLoop = false

        guard let player = player else { return }
        player.seek(to: .zero)
        player.playImmediately(atRate: 1.0)
    }

    private func handlePlaybackFinished() {
        hasPlayedOnce = true

        if dataFinishedLoading || shouldStopAfterFirstLoop {
            stopAndHide()
        } else {
            player?.seek(to: .zero)
            player?.playImmediately(atRate: 1.0)
        }
    }

    private func stopAndHide() {
        player?.pause()
        showVideo = false
        onVideoComplete()
    }

    private func resetState() {
        player?.seek(to: .zero)
        player?.pause()
        hasPlayedOnce = false
        shouldStopAfterFirstLoop = false
        showVideo = true
        player?.playImmediately(atRate: 1.0)
    }

    private func cleanupObserver() {
        if let token = observerToken {
            NotificationCenter.default.removeObserver(token)
            observerToken = nil
        }
        if let timeObserver = timeObserverToken {
            player?.removeTimeObserver(timeObserver)
            timeObserverToken = nil
        }

    }
}

import SwiftUI
import AVKit

struct ScaledVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill // This removes black bars
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
