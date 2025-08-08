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
    @EnvironmentObject var playbackManager: PlaybackManager

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
                                if playbackManager.currentlyPlayingID == viewModel.news.id {
                                    playbackManager.togglePlayPause()
                                } else if let url = URL(string: viewModel.news.audioURL ?? "") {
                                    playbackManager.startBackgroundAudio(
                                        from: url,
                                        title: viewModel.news.title,
                                        articleID: viewModel.news.id
                                    )
                                }
                            }) {
                                if playbackManager.isPlaying && playbackManager.currentlyPlayingID == viewModel.news.id {
                                    Image(systemName: "pause.circle.fill")
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
