//
//  ArticleListSectionView.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 03/08/25.
//

import SwiftUI
import AVFoundation
import MediaPlayer
import SDWebImageSwiftUI

import SwiftUI
import SDWebImageSwiftUI
import AVFoundation
import MediaPlayer

struct ArticleListSectionView: View {
    let section: ArticleListSection
    @StateObject private var viewModel: HomeViewModel
    var onSelectNews: ((NewsModel) -> Void)?
    @State private var isSharing: Bool = false
    @State private var audioPlayer: AVPlayer?
    @State private var isPlaying: Bool = false
    @State private var currentlyPlayingID: String? = nil
    
    init(section: ArticleListSection, viewModel: HomeViewModel, onSelectNews: ((NewsModel) -> Void)? = nil) {
        self.section = section
        self.onSelectNews = onSelectNews
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = section.title, !title.isEmpty {
                HStack {
                    Text(title)
                        .font(.headline)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                            .padding(8)
                    }
                }
                .padding(.bottom, 8)
                .padding(.horizontal)
            }
            
            if let articles = section.data {
                VStack(spacing: 0) {
                    ForEach(articles) { article in
                        VStack(alignment: .leading, spacing: 12) {
                            if let imageURLString = article.imageURL,
                               let url = URL(string: imageURLString),
                               article.id == articles.first?.id {
                                WebImage(url: url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                                    .padding(.bottom, 8)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if let title = article.title {
                                    Text(title)
                                        .font(.headline)
                                        .lineSpacing(4)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                if let description = article.description {
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineSpacing(4)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.top, 4)
                                } else {
                                    Spacer()
                                }
                                
                                HStack {
                                    Spacer()
                                    
                                    // LISTEN BUTTON (toggle play/pause)
                                    Button(action: {
                                        if currentlyPlayingID == article.id {
                                            if isPlaying {
                                                audioPlayer?.pause()
                                                isPlaying = false
                                            } else {
                                                audioPlayer?.play()
                                                isPlaying = true
                                            }
                                        } else {
                                            if let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") {
                                                startBackgroundAudio(from: url, title: article.title ?? "News Audio", articleID: article.id ?? "")
                                            }
                                        }
                                    }) {
                                        if isPlaying && currentlyPlayingID == article.id {
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
                                    
                                    // SAVE BUTTON
                                    Button(action: {
                                        viewModel.toggleBookmark(for: article)
                                    }) {
                                        Image("save")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(viewModel.savedNewsIDs.contains(article.id ?? "") ? .blue : .gray)
                                            .frame(width: 40, height: 40)
                                    }
                                    .onAppear {
                                        viewModel.loadSavedState(for: article.id ?? "")
                                    }
                                    
                                    // SHARE BUTTON
                                    Button(action: {
                                        let text = article.title ?? ""
                                        let url = URL(string: article.newsURL ?? "")
                                        
                                        var items: [Any] = [text]
                                        if let url = url { items.append(url) }
                                        
                                        viewModel.shareContent = items
                                        isSharing = true
                                    }) {
                                        Image("share")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            Divider().padding(.vertical, 8)
                        }
                        .padding(.vertical, 12)
                        .onTapGesture {
                            let item = NewsModel(
                                id: article.id ?? "",
                                title: article.title ?? "",
                                imageURL: article.imageURL ?? "",
                                newsDescription: article.description ?? "",
                                publishedTime: article.publishedTime ?? "",
                                PublishedDate: "",
                                newsURL: article.newsURL ?? ""
                            )
                            onSelectNews?(item)
                        }
                    }
                }
                .background(Color(.systemBackground))
            }
        }
        .sheet(isPresented: $isSharing) {
            ShareSheet(activityItems: viewModel.shareContent)
        }
        .background(Color(.systemBackground))
    }
}

extension ArticleListSectionView {
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
