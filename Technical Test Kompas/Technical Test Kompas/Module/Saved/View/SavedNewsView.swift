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
    @EnvironmentObject var playbackManager: PlaybackManager
    @State private var selectedNews: NewsModel?
    @State private var isSharing: Bool = false
    @State private var shareContent: [Any] = []
    var navigator: SavedNewsNavigator
    
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
                                if playbackManager.currentlyPlayingID == savedNews.id {
                                    playbackManager.togglePlayPause()
                                } else if let url = URL(string: savedNews.audioURL ?? "") {
                                    playbackManager.startBackgroundAudio(
                                        from: url,
                                        title: savedNews.title,
                                        articleID: savedNews.id
                                    )
                                }
                            }) {
                                if playbackManager.isPlaying && playbackManager.currentlyPlayingID == savedNews.id {
                                    Image(systemName: "pause.circle.fill")
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
                .environmentObject(playbackManager)
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
