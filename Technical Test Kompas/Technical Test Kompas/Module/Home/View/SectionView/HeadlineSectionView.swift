//
//  HeadlineSectionView.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 03/08/25.
//

import SwiftUI
import AVFoundation
import MediaPlayer
import SDWebImageSwiftUI

struct HeadlineSectionView: View {
    let content: HeadlineData
    var onSelectNews: ((NewsModel) -> Void)?

    @StateObject private var viewModel: HomeViewModel
    @State private var isSharing: Bool = false

    
    init(content: HeadlineData, viewModel: HomeViewModel, onSelectNews: ((NewsModel) -> Void)? = nil) {
        self.content = content
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSelectNews = onSelectNews
    }
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            VStack(alignment: .center) {
                Image("breaking_news")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)

            VStack(alignment: .center, spacing: 8) {
                if let headline = content.headline {
                    Text(headline)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                if let subheadline = content.subheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                HStack {
                    if let publishedTime = content.publishedTime {
                        Text(publishedTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button(action: {
                           
                        }) {
                            Image("listen")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                       
                        Button(action: {
                            let articleItem = ArticleListItem(title: content.headline,
                                                              label: "",
                                                              description: content.subheadline,
                                                              imageDescription: "",
                                                              mediaCount: 0,
                                                              imageURL: content.imageURL,
                                                              publishedTime: content.publishedTime,
                                                              publishedDate: "", id: content.id,
                                                              newsURL: content.newsURL)
                            viewModel.toggleBookmark(for: articleItem)
                        }) {
                            Image("save")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(viewModel.savedNewsIDs.contains(content.id ?? "") ? .blue : .gray)
                                .frame(width: 40, height: 40)
                        }
                        .onAppear {
                            viewModel.loadSavedState(for: content.id ?? "")
                        }
                        
                        Button(action: {
                            let text = content.headline ?? ""
                            let url = URL(string: content.newsURL ?? "")
                            
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
                .padding(.horizontal)
            }
            .onTapGesture {
                if let headline = content.headline, let id = content.id {
                    let item = NewsModel(id: id,
                                         title: headline,
                                         imageURL: content.imageURL ?? "",
                                         newsDescription: content.subheadline ?? "",
                                         publishedTime: content.publishedTime ?? "",
                                         PublishedDate: "",
                                         newsURL: content.newsURL ?? "")
                    onSelectNews?(item)
                }
            }
            
            if let imageURLString = content.imageURL, let url = URL(string: imageURLString) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .padding(.bottom, 8)
                    .onTapGesture {
                        if let headline = content.headline, let id = content.id {
                            let item = NewsModel(id: id,
                                                 title: headline,
                                                 imageURL: content.imageURL ?? "",
                                                 newsDescription: content.subheadline ?? "",
                                                 publishedTime: content.publishedTime ?? "",
                                                 PublishedDate: "", newsURL: content.newsURL ?? "")
                            onSelectNews?(item)
                        }
                    }
            }
            
            
            Divider()
                .padding(.vertical, 8)
            
            if let articles = content.articles {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(articles) { article in
                        VStack(alignment: .leading, spacing: 4) {
                            if let title = article.title {
                                Text(title)
                                    .font(.headline)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer()

                            
                            HStack {
                                if let articleTime = article.publishedTime {
                                    Text(articleTime)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack {
                                    Button(action: {
                                        
                                    }) {
                                        Image("listen")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    }
                                    
                                    Button(action: {
                                        let articleItem = ArticleListItem(title: article.title,
                                                                          label: "",
                                                                          description: "",
                                                                          imageDescription: "",
                                                                          mediaCount: 0,
                                                                          imageURL: article.imageURL ?? "",
                                                                          publishedTime: article.publishedTime,
                                                                          publishedDate: "", id: article.id, newsURL: article.newsURL ?? "")
                                        viewModel.toggleBookmark(for: articleItem)
                                    }) {
                                        Image("save")
                                            .resizable()
                                            .renderingMode(.template) // allow tinting
                                            .foregroundColor(viewModel.savedNewsIDs.contains(article.id) ? .blue : .gray)
                                            .frame(width: 40, height: 40)
                                    }
                                    .onAppear {
                                        viewModel.loadSavedState(for: article.id)
                                    }
                                    
                                    Button(action: {
                                        let text = article.title ?? ""
                                        let url = URL(string: article.newsURL ?? "")
                                        
                                        var items: [Any] = [text]
                                        if let url = url {
                                            items.append(url)
                                        }
                                        
                                        viewModel.shareContent = items
                                        isSharing = true
                                        
                                    }) {
                                        Image("share") // Use your asset name here
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    }
                                    
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                        }
                        .onTapGesture {
                            let item = NewsModel(id: article.id,
                                                 title: article.title ?? "",
                                                 imageURL: article.imageURL ?? "",
                                                 newsDescription: "",
                                                 publishedTime: article.publishedTime ?? "",
                                                 PublishedDate: "",
                                                 newsURL: article.newsURL ?? "")
                            onSelectNews?(item)
                        }
                        
                        
                    }
                }
                .padding(.horizontal)

            }
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $isSharing) {
            ShareSheet(activityItems: viewModel.shareContent)
        }
    }
    
}

