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

struct ArticleListSectionView: View {
    let section: ArticleListSection
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var playbackManager: PlaybackManager
    var onSelectNews: ((NewsModel) -> Void)?
    @State private var isSharing: Bool = false
    
    init(section: ArticleListSection, viewModel: HomeViewModel, onSelectNews: ((NewsModel) -> Void)? = nil) {
        self.section = section
        self.onSelectNews = onSelectNews
        _viewModel = ObservedObject(wrappedValue: viewModel)
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
                .padding(.vertical, 8)
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
                                    Button {
                                        if playbackManager.currentlyPlayingID == article.id {
                                            playbackManager.togglePlayPause()
                                        } else if let url = URL(string: article.audioURL ?? "") {
                                            playbackManager.startBackgroundAudio(
                                                from: url,
                                                title: article.title ?? "",
                                                articleID: article.id ?? ""
                                            )
                                        }
                                    } label: {
                                        if playbackManager.isPlaying && playbackManager.currentlyPlayingID == article.id {
                                            Image(systemName: "pause.circle.fill")
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
                                newsURL: article.newsURL ?? "",
                                audioURL: article.audioURL ?? ""
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
        .padding(.vertical)
    }
}

