//
//  DetailNewsView.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 06/08/25.
//

import Foundation
import SwiftUI
import AVFoundation
import MediaPlayer
import SDWebImageSwiftUI

struct DetailNewsView: View {
    @StateObject private var viewModel: DetailViewModel
    @State private var isSharing: Bool = false
    @State private var audioPlayer: AVPlayer?
    @State private var isPlaying: Bool = false
    @State private var currentlyPlayingID: String? = nil

    init(viewModel: DetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.news.title)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(viewModel.news.newsDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Text(viewModel.news.publishedTime)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        HStack(spacing: 8) {
                            Button(action: {
                                if currentlyPlayingID == viewModel.news.id {
                                    if isPlaying {
                                        audioPlayer?.pause()
                                        isPlaying = false
                                    } else {
                                        audioPlayer?.play()
                                        isPlaying = true
                                    }
                                } else {
                                    if let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") {
                                        startBackgroundAudio(from: url, title: viewModel.news.title ?? "News Audio", articleID: viewModel.news.id ?? "")
                                    }
                                }
                            }) {
                                if isPlaying && currentlyPlayingID == viewModel.news.id {
                                    Image(systemName: "pause.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                } else {
                                    Image("listen")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                }
                            }

                            Button(action: {
                                viewModel.toggleBookmark()
                            }) {
                                Image("save")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(viewModel.isSaved ? .blue : .gray)
                                    .frame(width: 40, height: 40)
                            }
                            .onAppear {
                                viewModel.loadSavedState()
                            }

                            Button(action: {
                                let text = viewModel.news.title
                                let url = URL(string: viewModel.news.newsURL)
                                
                                var items: [Any] = [text]
                                if let url = url {
                                    items.append(url)
                                }
                                
                                viewModel.shareContent = items
                                isSharing = true
                            }) {
                                Image("share")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.top)

                if let url = URL(string: viewModel.news.imageURL) {
                    WebImage(url: url)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .padding(.bottom, 8)
                }
            }
        }
        .navigationTitle("Detail Berita")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .sheet(isPresented: $isSharing) {
            ShareSheet(activityItems: viewModel.shareContent)
        }
        
    }
}
extension DetailNewsView {
    // MARK: - AUDIO BACKGROUND PLAYER
    private func startBackgroundAudio(from url: URL, title: String, articleID: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
        
        isPlaying = true
        
        currentlyPlayingID = articleID
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
        
        setupNowPlaying(title: title)
        
        // Keep lock screen scrubber in sync
        audioPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2),
                                             queue: .main) { time in
            var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(time)
            info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }
    
    private func setupNowPlaying(title: String) {
        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "News Reader"
        
        if let currentItem = audioPlayer?.currentItem {
            let duration = CMTimeGetSeconds(currentItem.asset.duration)
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { _ in
            audioPlayer?.play()
            isPlaying = true
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { _ in
            audioPlayer?.pause()
            isPlaying = false
            return .success
        }
        
        // Allow timestamp scrubbing from lock screen
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
                let time = CMTime(seconds: positionEvent.positionTime, preferredTimescale: 1)
                audioPlayer?.seek(to: time)
                return .success
            }
            return .commandFailed
        }
    }
    
}
