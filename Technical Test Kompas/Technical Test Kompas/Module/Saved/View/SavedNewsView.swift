//
//  SavedNewsView.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 06/08/25.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import AVFoundation
import MediaPlayer

struct SavedNewsView: View {
    @StateObject private var viewModel: SavedNewsViewModel
    @State private var selectedNews: NewsModel?
    @State private var isSharing: Bool = false
    @State private var shareContent: [Any] = []
    var navigator: SavedNewsNavigator
    @State private var audioPlayer: AVPlayer?
    @State private var isPlaying: Bool = false
    @State private var currentlyPlayingID: String? = nil
    
    init(viewModel: SavedNewsViewModel, navigator: SavedNewsNavigator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.navigator = navigator
    }
    
    var body: some View {
        List {
            ForEach(viewModel.savedNews) { savedNews in
                VStack(alignment: .leading, spacing: 12) {
                    if let url = URL(string: savedNews.imageURL) {
                        WebImage(url: url)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .padding(.bottom, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(savedNews.title)
                            .font(.headline)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if !savedNews.newsDescription.isEmpty {
                            Text(savedNews.newsDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                        } else {
                            Spacer()
                        }
                        HStack {
                            Text(savedNews.publishedTime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            
                            Spacer()
                            
                            // LISTEN BUTTON (toggle play/pause)
                            Button(action: {
                                if currentlyPlayingID == savedNews.id {
                                    if isPlaying {
                                        audioPlayer?.pause()
                                        isPlaying = false
                                    } else {
                                        audioPlayer?.play()
                                        isPlaying = true
                                    }
                                } else {
                                    if let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") {
                                        startBackgroundAudio(from: url, title: savedNews.title, articleID: savedNews.id)
                                    }
                                }
                            }) {
                                if isPlaying && currentlyPlayingID == savedNews.id {
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
                                viewModel.removeSave(for: savedNews)
                            }) {
                                Image("save")
                                    .resizable()
                                    .renderingMode(.template) 
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                            }
                            
                            
                            Button(action: {
                                let text = savedNews.title
                                let url = URL(string: savedNews.newsURL)
                                
                                var items: [Any] = [text]
                                if let url = url {
                                    items.append(url)
                                }
                                
                                shareContent = items
                                isSharing = true
                            }) {
                                Image("share")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                        }
                        
                        
                    }
                    .padding(.horizontal)
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .contentShape(Rectangle())
                .buttonStyle(PlainButtonStyle())
                .onTapGesture {
                    selectedNews = savedNews
                }
            }
        }
        .listStyle(PlainListStyle())
        .onAppear {
            viewModel.getSavedNews()
        }
        .navigationDestination(item: $selectedNews) { news in
            navigator.makeDetailView(for: news)
        }
        .navigationTitle("Berita Tersimpan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .sheet(isPresented: $isSharing) {
            ShareSheet(activityItems: shareContent)
        }
        
    }
}

extension SavedNewsView {
    // MARK: - AUDIO BACKGROUND PLAYER
    private func startBackgroundAudio(from url: URL, title: String, articleID: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
        
        currentlyPlayingID = articleID
        isPlaying = true
        
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
